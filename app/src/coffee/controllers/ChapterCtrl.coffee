class ChapterCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->  
        # True if the given chapter is visible
        @scope.shouldShowChapter = (chapter)=> chapter.id is @User.chapter        
# EOF
