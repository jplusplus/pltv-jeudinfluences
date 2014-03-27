angular.module("spin.service").factory "User", ['$http', 'config.api', 'Plot', 'localStorageService', '$location', '$rootScope', ($http, api, Plot, localStorageService, $location, $rootScope)->
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
            @chapter  = 1
            @scene    = 1
            @sequence = 0
            # Indicators
            @ubm      = ~~(Math.random()*100)
            @trust    = ~~(Math.random()*100)
            @stress   = ~~(Math.random()*100)     
            # Load career data from the API
            do @loadCareer
            # Update chapter, scene and sequence according the last scene of the career array
            $rootScope.$watch (=>@career), @updateProgression, yes
            # Update local storage
            $rootScope.$watch (=>@), @updateLocalStorage, yes
            return @

        updateLocalStorage: (user=@)=>
            localStorageService.set("user", user) if user?

        updateProgression: (career=@career)=>
            # Do we start acting?
            unless career.length is 0
                console.log career


        loadCareer: =>
            # Get or create career 
            method = if @token? then "get" else "post"            
            params = if @token? then "token=#{@token}" else ""
            # Get value using the token
            $http[method]("#{api.career}?#{params}", {})
                # Save the token
                .then (body)=>
                    @token  = body.data.token
                    @career = body.data.history if body.data.history?

        nextSequence: =>   
            if Plot.sequence(@chapter, @scene, @sequence + 1)?                
                # Go simply to the next sequence
                ++@sequence 
            else if Plot.scene(@chapter, @scene + 1)?                
                # Restore sequence
                @sequence = 0
                # And go the next scene
                ++@scene
            else if Plot.chapter(@chapter+1)?
                # Restore sequence and scene
                @sequence = 0
                @scene    = Plot.chapter(@chapter+1).scene[0].id
                # And go the next scene
                ++@chapter
]
# EOF