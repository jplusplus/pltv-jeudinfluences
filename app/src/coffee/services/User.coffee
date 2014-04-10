angular.module("spin.service").factory("User", [
    '$http'
    '$timeout'
    'constant.api'
    'constant.settings'
    'Plot'
    'localStorageService'
    '$location'
    '$rootScope'
    ($http, $timeout, api, settings, Plot, localStorageService, $location, $rootScope)->
        new class User
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                # This user is saved into local storage
                master = localStorageService.get("user") or {}
                indicators_settings = settings.user_indicators
                # False until the player starts the game
                @inGame     = no
                @isGameOver = no
                @isGameDone = no
                # User authentication
                @token    = $location.search().token or master.token or null
                @email    = master.email or null
                # User progression
                @career   = master.career or []            
                # Sound control
                @volume   = if isNaN(master.volume) then 0.5 else master.volume         
                # Position
                @chapter  = master.chapter  or "1"
                @scene    = master.scene    or "1"
                @sequence = master.sequence or 0
                @indicators =
                    # Visible indicators
                    stress : master.stress  or indicators_settings.stress.start
                    trust  : master.trust   or indicators_settings.trust.start
                    ubm    : master.ubm     or indicators_settings.ubm.start
                    # Hidden indicators
                    guilt  : master.guilt   or 0 
                    honesty: master.honesty or 100 
                    karma  : master.karma   or 0 
                # Load career data from the API
                # do @loadCareer
                return @

            pos: ()=> @chapter + "." + @scene

            newUser: ()=>
               # Reset identication tokens
                [@token, @email] = [null, null] 
                # Reset progression
                [@chapter, @scene, @sequence] = ["1", "1", 0]
                # And create a new session
                @loadCareer()

            updateLocalStorage: (user=@)=>
                localStorageService.set("user", user) if user?

            updateProgression: (career)=>
                # Do we start acting?
                if career.reached_scene? and typeof(career.reached_scene) is String
                    [@chapter, @scene] = career.reached_scene.split "."
                    # Save indicators                        
                    @indicators.karma  = career.context.karma
                    @indicators.stress = career.context.stress
                    @indicators.trust  = career.context.trust
                    @indicators.ubm    = career.context.ubm
                    # Start to the first sequence
                    @sequence = 0
                do @checkProgression

            checkProgression: => 
                is_gameover = no 
                breakme     = no 
                # while a game over has not been detected or "break" like 
                # instruction is set we loop (I dont like break) 
                while (is_gameover is no) and (breakme is no)
                    for key, value of @indicators
                        indicator_settings = settings.user_indicators[key]
                        if indicator_settings
                            is_gameover = indicator_settings.isgameover(value)
                    breakme = yes

                @isGameOver = is_gameover
                is_gameover

            isStartingChapter: =>                 
                # Chapter is considered as starting during {settings.chapterStarting} millisecond
                Date.now() - @lastChapterChanging < settings.chapterStarting

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
                        .success( (data)=> @updateProgression(data) )
                        # Something wrong happends, restores the User model
                        .error( (data)=> do @newUser if @token? or @email? )
                else if @email?
                    $http.get("#{api.career}?email=#{@email}")
                        # Update chapter, scene and sequence according
                        # the last scene given by the career
                        .success( (data)=> @updateProgression(data) )
                        # The mail isn't associated to a career
                        # We create a new one and associate the email
                        .error (data) =>
                            @createNewCareer yes
                # Or create a new one
                else
                    do @createNewCareer

            createNewCareer: (associate=no) =>
                # Get value using the token
                $http.post("#{api.career}", reached_scene: "1.1")
                    # Save the token
                    .success (data)=>
                        # Save the token
                        @token = data.token
                        (do @associate) if associate
                        # And call this function again
                        do @loadCareer

            propagateChoice: (option)=>                                           
                for key, indicator of option.result[0] 
                    @indicators[key] += parseInt(indicator)
                do @updateLocalStorage

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
                        # Same choice variables
                        @propagateChoice(option)                        
                else
                    state = reached_scene: @pos()
                # Get value using the token
                $http.post "#{api.career}?token=#{@token}", state
                # And load the refresfed data
                do @loadCareer

            nextSequence: =>   
                scene = Plot.scene(@chapter, @scene)
                # Go to the next sequence within the current scene
                if Plot.sequence(@chapter, @scene, @sequence + 1)?                
                    # Go simply to the next sequence
                    ++@sequence 
                    # Return the new sequence
                    Plot.sequence(@chapter, @scene, @sequence)
                # Go the next scene
                else if scene and scene.next_scene?
                    @goToScene scene.next_scene   
                    # Return the new sequence
                    Plot.sequence(@chapter, @scene, @sequence)

            associate: =>
                return if (not @email?) or @email is ""
                ($http
                    url : "#{api.associate}?token=#{@token}"
                    method : 'PUT'
                    data :
                        email : @email
                ).success (data) =>
                    console.debug data

            goToScene: (next_scene, shouldUpdateCareer=yes)=>
                if typeof(next_scene) is typeof("")
                    next_scene_str = next_scene
                else
                    karma_key = if @indicators.karma >= 0 then 'positif' else 'negatif'
                    next_scene_str = next_scene["#{karma_key}_karma"]

                [chapter, scene] = next_scene_str.split "."

                # Check that the next step exists
                warn = (m)-> console.warn "#{m} doesn't exist (#{next_scene_str})."
                # Chapter exits?
                return warn('Chapter') unless Plot.chapter(chapter)?           
                # Scene exits?
                return warn('Scene') unless Plot.scene(chapter, scene)?                       
                # If we effectively change
                if @chapter isnt chapter or @scene isnt scene
                    # Update values
                    [@chapter, @scene, @sequence] = [chapter, scene, 0]
                    # Save the career
                    do @updateCareer if shouldUpdateCareer
                else
                    # Next sequence exits?
                    return warn('Next sequence') unless Plot.sequence(chapter, scene, @sequence+1)?  
                    # Just go further
                    @sequence++   
])