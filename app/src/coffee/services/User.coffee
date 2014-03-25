angular.module("spin.service").factory "User", ['Plot', (Plot)->
    new class User
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: -> 
            # Sound control
            @volume   = 50
            # Position
            @chapter  = 1
            @scene    = 1
            @sequence = 0
            # Indicators
            @ubm      = ~~(Math.random()*100)
            @trust    = ~~(Math.random()*100)
            @stress   = ~~(Math.random()*100)        
            return @
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