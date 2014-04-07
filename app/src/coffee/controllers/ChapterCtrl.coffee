class ChapterCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->                          
        @scope.plot  = @Plot
        @scope.user  = @User 
        # Establishes a bound between "src" argument 
        # provided by the chapter directive and the Countroller
        @chapter = @scope.chapter = @scope.src     
        # True if the given chapter is visible
        @scope.shouldShowChapter = => @chapter.id is @User.chapter and @User.inGame
        # Returns the class to apply to the Chapter
        @scope.chapterClasses = =>
            "chapter--starting": User.isStartingChapter()

angular.module('spin.controller').controller("ChapterCtrl", ChapterCtrl)
# EOF
