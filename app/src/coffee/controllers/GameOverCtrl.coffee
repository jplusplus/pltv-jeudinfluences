class GameOverCtrl
    @$inject: ['$scope', 'constant.gameover-sentences', 'User']
    constructor: (@scope, sentences, @User) ->  
        @scope.gameOverSentence = =>
            @User.gameOverSentence or sentences.default
            
        @scope.user  = @User
        @scope.restart = =>
            @User.restartChapter()


# EOF