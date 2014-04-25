class GameOverCtrl
    @$inject: ['$scope']
    constructor: (@scope) ->  
        @scope.restart = =>
            @User.restartChapter()


# EOF