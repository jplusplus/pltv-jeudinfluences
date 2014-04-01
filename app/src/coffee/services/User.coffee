angular.module("spin.service").factory("User", [
    '$http'
    '$timeout'
    'constant.api'
    'constant.delay'
    'Plot'
    'localStorageService'
    '$location'
    '$rootScope'
    ($http, $timeout, api, delay, Plot, localStorageService, $location, $rootScope)->
        new class User
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->                                 
                # This user is saved into local storage
                master    = localStorageService.get("user") or {}
                # False until the player starts the game
                @inGame   = yes
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
                # Indicators
                @ubm      = master.ubm    or 0
                @trust    = master.trust  or 0
                @stress   = master.stress or 0    
                @karma    = master.karma  or 100 
                # Load career data from the API
                do @loadCareer
                # Record begining date of a chapter
                $rootScope.$watch (=> [@chapter, @inGame]), @saveChapterChanging, yes
                # Update local storage
                $rootScope.$watch (=>@), @updateLocalStorage, yes
                return @

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
                    @karma  = career.context.karma
                    @stress = career.context.stress
                    @trust  = career.context.trust
                    @ubm    = career.context.ubm
                    # Start to the first sequence
                    @sequence = 0

            isStartingChapter: =>                 
                # Chapter is considered as starting during {delay.chapterStarting} millisecond
                Date.now() - @lastChapterChanging < delay.chapterStarting

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
                # Get or create career 
                method = if @token? or @email? then "get" else "post"            
                # We can use the token XOR the email to retreive the session
                params = if @token? then "token=#{@token}" else ""
                params = if @email? then "email=#{@email}" else params                                
                state  = if method is "post" then {reached_scene: @scene + "." + @scene} else {}
                # Get value using the token
                $http[method]("#{api.career}?#{params}", state)
                    # Save the token
                    .success (data)=>
                        @token  = data.token
                        # Update chapter, scene and sequence according 
                        # the last scene of the career array
                        @updateProgression(data)
                    # Something wrong happends
                    .error (error)=>                    
                        # Restore the User model
                        do @newUser if @token? or @email?   

            updateCareer: (choice)=>
                return no unless @token
                # Add reached scene parameter
                state = if choice? then choice else reached_scene: @scene + "." + @scene                       
                # Get value using the token
                $http.post "#{api.career}?token=#{@token}", state

            nextSequence: =>   
                if Plot.sequence(@chapter, @scene, @sequence + 1)?                
                    # Go simply to the next sequence
                    ++@sequence 
                else if @scene.next_scene?
                    @goToScene @scene.next_scene                    

            goToScene: (str)=>
                [chapter, scene] = str.split "."              
                # Check that the next step exists
                warn = (m)-> console.warn "#{m} doesn't exist (#{str})."
                # Chapter exits?
                return warn('Chapter') unless Plot.chapter(chapter)?           
                # Scene exits?
                return warn('Scene') unless Plot.scene(chapter, scene)?                       
                # If we effectively change
                if @chapter isnt chapter or @scene isnt scene
                    # Update values
                    [@chapter, @scene, @sequence] = [chapter, scene, 0]
                    # Save the career
                    do @updateCareer
                else
                    # Next sequence exits?
                    return warn('Next sequence') unless Plot.sequence(chapter, scene, @sequence+1)?  
                    # Just go further
                    @sequence++   
])