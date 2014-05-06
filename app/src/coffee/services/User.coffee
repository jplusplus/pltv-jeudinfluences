angular.module("spin.service").factory("User", [
    'constant.api'
    'constant.settings'
    'constant.types'
    'TimeoutStates'
    'UserIndicators'
    'Plot'
    'localStorageService'
    '$http'
    '$timeout'
    '$location'
    '$rootScope'
    (api, settings, types, TimeoutStates, UserIndicators, Plot, localStorageService, $http, $timeout, $location, $rootScope)->
        new class User
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor: ->
                # This user is saved into local storage
                master = localStorageService.get("user") or {}
                # Set initial value according to the localStorage
                @setInitialValues master
                # User authentication
                @token    = $location.search().token or master.token or null
                @email    = master.email or null
                if (do $location.search).token?
                    @email = yes if @email is null
                    $location.search 'token', null
                # Load the career if a token is given
                do @loadCareer if @token isnt null
                # Load career data from the API when the player enters the game
                $rootScope.$watch (=>@inGame), (newValue, oldValue) =>
                    if @token is null and newValue and not oldValue
                        do @loadCareer 
                , yes
                return @

            setInitialValues: (master={})=>
                # Scenes the user passed
                @scenes   = master.scenes or []
                # Sound control
                @volume   = if isNaN(master.volume) then 1 else master.volume
                # Reset identication tokens
                [@token, @email] = [null, null] 
                # Reset user states 
                @inGame = @isGameOver = @isGameDone = @isSummary  = @isReady = no
                # Reset progression
                [@chapter, @scene, @sequence] = ["1", "1", 0]
                # User progression indiciators
                @indicators =
                    # Visible indicators
                    stress  : UserIndicators.stress.meta.start
                    trust   : UserIndicators.trust.meta.start
                    ubm     : UserIndicators.ubm.meta.start
                    # Hidden indicators
                    guilt   : 0
                    honesty : 0
                    karma   : 0 

                # Load career data from the API when the player enters the game
                $rootScope.$watch =>
                    @inGame
                , (newValue, oldValue) =>
                    if newValue and not oldValue
                        do @loadCareer
                , yes

                return @

            pos: ()=> @chapter + "." + @scene

            chapterProgression: ()=>
                return 100 if @isSummary
                inter =_.intersection settings.mainScenes[@chapter], @scenes
                Math.round( Math.min(inter.length, 4)/4 * 100)

            newUser: ()=>
                # Remove value in localStorage
                do localStorageService.clearAll
                do @setInitialValues

            updateLocalStorage: (user=@)=>
                localStorageService.set("user", user) if user?

            updateProgression: (career)=>
                # Do we start acting?
                if career.reached_scene? and typeof(career.reached_scene) is "string"
                    unless TimeoutStates.feedback isnt undefined
                        [@chapter, @scene] = career.reached_scene.split "."
                        # Saved passed scenes
                        @scenes = career.scenes
                        # Save indicators
                        for own key, value of career.context
                            @indicators[key] = value
                        # Start to the first sequence
                        @sequence = 0
                        # Check that the sequence's condition is OK
                        if not do @isSequenceConditionOk
                            # If not, go to the next sequence
                            do @nextSequence
                if @checkProgression()
                    @isGameOver = yes

            checkProgression: =>
                # return false if user is in game over
                return unless @inGame
                gameOver = false 
                # will check if user progression lead him to a game over.
                for key, value of @indicators
                    if UserIndicators[key]? and UserIndicators[key].isGameOver(value)
                        @gameOverReason = key
                        gameOver =yes
                        break
                gameOver

            isStartingChapter: =>       
                # Chapter is considered as starting during {settings.chapterEntrance} millisecond
                Date.now() - @lastChapterChanging < settings.chapterEntrance or
                # The user may also be ready (all image loaded)
                not @isReady

            saveChapterChanging: (chapter)=>
                # Stop here until a chapter id is set
                return unless chapter?
                @lastChapterChanging = Date.now()            
                # Cancel any current timeout
                if @trackChapterChanging? then $timeout.cancel @trackChapterChanging
                # Start the tracking loop
                do @chapterTrackingLoop
            
            chapterTrackingLoop: =>      
                if not @isStartingChapter() and @trackChapterChanging?
                    # Stop until chapter is effectively not starting
                    $timeout.cancel(@trackChapterChanging) 
                else
                    # Force Angular to process a digest regulary
                    @trackChapterChanging = $timeout @chapterTrackingLoop, 200

            loadCareer: =>
                # Get career 
                if @token?
                    # Get value using the token
                    $http.get("#{api.career}?token=#{@token}")
                        # Update chapter, scene and sequence according 
                        # the last scene given by the career
                        .success( @updateProgression )
                        # Something wrong happends, restores the User model
                        .error (data)=> do @newUser if @token? or @email?
                # Or create a new one
                else
                    @createNewCareer (@email?)

            createNewCareer: (associate=no) =>
                # Get value using the token
                $http.post("#{api.career}", reached_scene: "1.1")
                    # Save the token
                    .success (data)=>
                        # Save the token
                        @token = data.token
                        (@associate @email) if associate
                        # And call this function again
                        do @loadCareer

            updateCareer: (choice)=>
                return no unless @token
                # Add reached scene parameter
                if choice? 
                    state = choice
                    [chapterIdx, sceneIdx] = choice.scene.split(".")
                    # Get the current sequence to  update the indicators
                    sequence = Plot.sequence(chapterIdx, sceneIdx, @sequence)
                    # Propagate the choices only if this sequence has options
                    if sequence.options?
                        option = sequence.options[choice.choice]
                        state.reached_scene = option.next_scene
                else
                    state = reached_scene: @pos()                  
                
                state.is_game_done = @isGameDone
                # Get value using the token
                $http.post("#{api.career}?token=#{@token}", state).success @updateProgression

            nextSequence: =>
                # will show next sequence or next scene if next sequence in 
                # current scene doesn't exists
                scene        = Plot.scene(@chapter, @scene)
                lastSequence = Plot.sequence(@chapter, @scene, @sequence)

                if lastSequence.result and @isSequenceConditionOk lastSequence 
                    for key, value of lastSequence.result
                        @indicators[key] += value
                        gameOver = do @checkProgression
                        if gameOver
                            @isGameOver = true
                unless @isGameOver
                    # Go to the next sequence within the current scene
                    if Plot.sequence(@chapter, @scene, @sequence + 1)? 
                        # Go simply to the next sequence
                        ++@sequence 
                        # Retrieve the new sequence and check conditions
                        sequence = Plot.sequence(@chapter, @scene, @sequence)
                        if not @isSequenceConditionOk sequence
                            sequence = do @nextSequence
                    # Go the next scene
                    else if scene and scene.next_scene?
                        # Shouldn't we reset to first sequence here?
                        @goToScene scene.next_scene   
                        # Return the new sequence
                        sequence = Plot.sequence(@chapter, @scene, @sequence)
                
                sequence
                
            isSequenceConditionOk: (seq) =>              
                # check that every sequence condition are met or not. 
                # condition are set with variables while doing some choices
                seq = seq or Plot.sequence @chapter, @scene, @sequence  
                return true unless seq?
                is_ok = @userMeetSequenceConditions(seq)
                if seq.isSkipped()
                    is_ok = no
                if seq.isGameOver()
                    $rootScope.safeApply =>
                        @isGameOver = true
                is_ok

            userMeetSequenceConditions: (seq)=>
                is_ok = yes
                seq = seq or Plot.sequence @chapter, @scene, @sequence  
                return true unless seq?
                if seq.condition
                    for key, value of seq.condition
                        user_variable_value = @indicators[key]
                        unless user_variable_value?
                            user_variable_value = false
                        is_ok = is_ok and (user_variable_value is value)
                is_ok

            associate: (email) =>
                return if (not email?) or email is ""
                $http
                    url : "#{api.associate}?token=#{@token}"
                    method : 'POST'
                    data :
                        email : email

            goToScene: (next_scene, shouldUpdateCareer=yes)=>
                if TimeoutStates.feedback 
                    # if a previous timeout was set for a previous feedback
                    # we delete it
                    TimeoutStates.feedback = undefined 

                if typeof(next_scene) is typeof("")
                    next_scene_str = next_scene
                else
                    karma_key = if @indicators.karma >= 0 then 'positif' else 'negatif'
                    next_scene_str = next_scene["#{karma_key}_karma"]

                if next_scene_str is types.scene.theEnd
                    @isGameDone = true
                    @inGame = false
                    @singMeTheEnd()
                    do @updateCareer if shouldUpdateCareer
                    return

                [chapter, scene] = next_scene_str.split "."

                # Check that the next step exists
                warn = (m)-> console.warn "#{m} doesn't exist (#{next_scene_str})."
                # Chapter exits?
                return warn('Chapter') unless Plot.chapter(chapter)?
                # Scene exits?
                return warn('Scene') unless Plot.scene(chapter, scene)?
                # If we effectively change
                if @chapter isnt chapter or @scene isnt scene
                    gameOver = @checkProgression()
                    unless gameOver
                        # Update values
                        [@chapter, @scene, @sequence] = [chapter, scene, 0]

                        # Check that the sequence's condition is OK
                        if not do @isSequenceConditionOk
                            # If not, go to the next sequence
                            do @nextSequence
                        # Save the career
                        do @updateCareer if shouldUpdateCareer
                else
                    # Next sequence exits?
                    return warn('Next sequence') unless Plot.sequence(chapter, scene, @sequence+1)?  
                    # Just go further
                    do @nextSequence

            restart: =>
                @inGame = @isSummary = @isGameDone = @isGameOver = no
                @newUser()

            restartChapter: =>
                # will restart churrent chapter to its first scene.
                @inGame     = yes
                @isSummary  = no
                @isGameOver = no
                (do @eraseCareerChapter).success @updateProgression


            leaveSummary: => 
                @isSummary = no
                @saveChapterChanging true

            eraseCareerSinceNow: =>
                $http
                    url : "#{api.erase}?token=#{@token}"
                    method : 'POST'
                    data :
                        since : @chapter + '.' + @scene

            eraseCareerChapter: =>
                $http
                    url : "#{api.erase}?token=#{@token}"
                    method : 'POST'
                    data :
                        chapter : @chapter

])
