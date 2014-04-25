class WelcomeCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->  
        @scope.email = @User.email
        # Takes the chapter only when the controller is instanciated
        @token       = @User.token

        @scope.submit = =>
            # Saves the email
            @User.email  = @scope.email
            # And starts the game!
            @User.inGame = yes

        # True if the user is a new one
        @scope.isNewUser = => not @token?
        # Start the game by activating the using
        @scope.startGame = =>@User.inGame = yes
        # Start a new party
        @scope.newGame = => 
            # Creates a new user
            do @User.newUser
            # And starts the game!
            @User.inGame = yes

        @scope.shouldShowWelcome = => not @User.inGame and not @User.isGameDone


angular.module('spin.controller').controller("WelcomeCtrl", WelcomeCtrl)
# EOF