class WelcomeCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->  
        @scope.user  = @User
        @scope.email = @User.email

        @scope.submit = =>
            # Saves the email
            @User.email  = @scope.email
            # And starts the game!
            @User.inGame = yes
# EOF