class GameOverCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->  
        @scope.user  = @User
        @scope.email = @User.email

        @scope.gameOverMan = =>
            @User.restartChapter()


# EOF