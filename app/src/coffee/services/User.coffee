class User
    @$inject: ['$http', 'Plot']

    # ──────────────────────────────────────────────────────────────────────────
    # Public method
    # ──────────────────────────────────────────────────────────────────────────
    constructor: (@Plot)-> 
        # Position
        @chapter = "1"
        @scene   = "1"
        # Indicators
        @ubm     = ~~(Math.random()*100)
        @trust   = ~~(Math.random()*100)
        @stress  = ~~(Math.random()*100)

        return @

        

angular.module("spin.service").factory "User", User
# EOF