class ChapterCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->     
        # Starts with the fist chapter (no shit Sherlock)
        @scope.$watch @User.chapter, (c)-> @scope.currentChapter = c
# EOF
