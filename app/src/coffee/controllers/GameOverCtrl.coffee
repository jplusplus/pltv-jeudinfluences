class GameOverCtrl
    @$inject: ['$scope', 'constant.gameover-sentences', 'User']
    constructor: (@scope, sentences, @User) ->  
        @scope.gameOverSentence = =>
            sentences[@User.gameOverReason or 'default']
            
        @scope.user  = @User

        @scope.restart = =>
            @scope.safeApply @User.restartChapter


# EOF