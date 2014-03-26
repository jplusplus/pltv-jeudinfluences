angular.module("spin.service").factory "User", ['Plot', 'localStorageService', '$rootScope', (Plot, localStorageService, $rootScope)->
    new class User
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: -> 
            # This user is saved into local storage
            master    = localStorageService.get("user") or {}
            # User authentication
            @token    = master.token or null
            @email    = master.email or null
            # Sound control
            @volume   = master.volume or 0.5
            # Position
            @chapter  = 1
            @scene    = 1
            @sequence = 0
            # Indicators
            @ubm      = ~~(Math.random()*100)
            @trust    = ~~(Math.random()*100)
            @stress   = ~~(Math.random()*100)     
            # Update local storage
            $rootScope.$watch (=>@), @updateLocalStorage, yes
            return @

        updateLocalStorage: (user=@)=> 
            localStorageService.set("user", user) if user?

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