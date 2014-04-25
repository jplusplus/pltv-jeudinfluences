class GameOverCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->  
        @scope.user  = @User
        @scope.restart = =>
            @User.restartChapter()


# EOF