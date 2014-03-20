class User
    @$inject: ['$http', 'Plot']

    # ──────────────────────────────────────────────────────────────────────────
    # Public method
    # ──────────────────────────────────────────────────────────────────────────
    constructor: (@Plot)-> 
        @chapter = 1
        return @

        

angular.module("spin.service").factory "User", User
# EOF