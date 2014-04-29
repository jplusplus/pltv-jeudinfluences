class WelcomeCtrl
    @$inject: ['$scope', 'User', '$timeout']
    constructor: (@scope, @User, @timeout) ->  
        @scope.user  = @User
        @scope.email = @User.email
        # Takes the chapter only when the controller is instanciated
        @token       = @User.token
        # Guide visible steps
        @scope.showHeadphone = @scope.showControl = no
        # Delay between each step of the guide
        @guideStepDelay = 4000

        @scope.submit = =>
            # Saves the email
            @User.email  = @scope.email
            # And starts the game!
            @User.inGame = yes

        # True if the user is a new one
        @scope.isNewUser = => not @token?
        # Start the game by activating the using
        @scope.startGame = (guide=yes)=>            
            return @User.inGame = yes unless guide
            # Show headphone guide's step
            @scope.showHeadphone = yes
            # Delay second step
            @timeout =>
                # Show control guide's step
                @scope.showControl  = yes
                # Delay launching
                @timeout (=> @User.inGame = yes), @guideStepDelay
                # Reset value after a short delay
                @timeout (=> @scope.showHeadphone = @scope.showControl = no), @guideStepDelay * 2
            , @guideStepDelay



        # Start a new party
        @scope.newGame = => 
            # Creates a new user
            do @User.newUser
            # And starts the game!
            @User.inGame = yes

        @scope.shouldShowWelcome = => not @User.inGame and not @User.isGameDone


angular.module('spin.controller').controller("WelcomeCtrl", WelcomeCtrl)
# EOF