angular.module("spin.service").factory "User", ['$http', 'constant.api', 'Plot', 'localStorageService', '$location', '$rootScope', ($http, api, Plot, localStorageService, $location, $rootScope)->
    new class User
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: -> 
            # This user is saved into local storage
            master    = localStorageService.get("user") or {}
            # User authentication
            @token    = $location.search().token or master.token or null
            @email    = master.email or null
            # User progression
            @career   = master.career or []            
            # Sound control
            @volume   = if isNaN(master.volume) then 0.5 else master.volume         
            # Position
            @chapter  = master.chapter  or 1
            @scene    = master.scene    or 1
            @sequence = master.sequence or 0
            # Indicators
            @ubm      = master.ubm    or 0
            @trust    = master.trust  or 0
            @stress   = master.stress or 0    
            @karma    = master.karma  or 100 
            # Load career data from the API
            # do @loadCareer
            # Update chapter, scene and sequence according the last scene of the career array
            $rootScope.$watch (=>@career), @updateProgression, yes
            # Update local storage
            $rootScope.$watch (=>@), @updateLocalStorage, yes
            return @

        newUser: ()=>
            # Reset identication tokens
            [@token, @email] = [null, null] 
            # Reset progression
            [@chapter, @scene, @sequence] = [1, 1, 0]
            # And create a new session
            @loadCareer()

        updateLocalStorage: (user=@)=>
            localStorageService.set("user", user) if user?

        updateProgression: (career=@career)=>
            # Do we start acting?
            if career.reached_scene?
                [@chapter, @scene] = career.reached_scene.split "."
                # Save indicators                        
                @karma  = career.context.karma
                @stress = career.context.stress
                @trust  = career.context.trust
                @ubm    = career.context.ubm
                # Start to the first sequence
                @sequence = 0

        loadCareer: =>
            # Get or create career 
            method = if @token? or @email? then "get" else "post"            
            # We can use the token XOR the email to retreive the session
            params = if @token? then "token=#{@token}" else ""
            params = if @email? then "email=#{@email}" else params
            # Create initial
            # Get value using the token
            $http[method]("#{api.career}?#{params}", {})
                # Save the token
                .success (data)=>
                    @token  = data.token
                    @career = data.history if data.history?
                # Something wrong happends
                .error (error)=>                    
                    # Restore the User model
                    do @newUser if @token? or @email?                        

        nextSequence: =>   
            if Plot.sequence(@chapter, @scene, @sequence + 1)?                
                # Go simply to the next sequence
                ++@sequence 
            else if @scene.next_scene? and Plot.scene(@chapter, @scene.next_scene)?                
                # Restore sequence
                @sequence = 0
                # And go to the next scene
                [@chapter, @scene] = @scene.next_scene.split(".")
            else if Plot.chapter(@chapter+1)?
                # Restore sequence and scene
                @sequence = 0
                @scene    = Plot.chapter(@chapter+1).scene[0].id
                # And go the next scene
                ++@chapter

        nextScene: (str)=>
            [chapter, scene] = str.split "."              
            # Check that the next step exists
            warn = (m)-> console.warn "#{m} doesn't exist (#{str})."
            # Chapter exits?
            return warn('Chapter') unless Plot.chapter(chapter)?           
            # Scene exits?
            return warn('Scene') unless Plot.scene(chapter, scene)?                       
            # If we effectively change
            if 1*@chapter isnt 1*chapter or 1*@scene isnt 1*scene
                # Update values
                [@chapter, @scene, @sequence] = [chapter, scene, 0]
            else
                # Next sequence exits?
                return warn('Next sequence') unless Plot.sequence(chapter, scene, @sequence+1)?  
                # Just go further
                @sequence++   
]
# EOF