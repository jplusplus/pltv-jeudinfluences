class ResultsCtrl
    @$inject: ['$scope', '$sce', 'Progression', 'User', 'Plot', 'Results']

    

    constructor: (@scope, @sce, @Progression, @User,  @Plot,  @Results)->
        # scope variable binding
        @scope.plot    = @Plot
        @scope.user    = @User
        @scope.chapter = 0
        
        # scope function binding
        @scope.shouldShowResults = => @User.isGameDone
        @scope.goNextChapter     = => @scope.chapter += 1
        @scope.hasMoreResults    = @hasMoreResults

        # scope watches
        @scope.$watch 'chapter', @onChapterIndexChanged
        @scope.$watch =>
                _.keys(@Results.list).length
            , (results_count)=>
                if results_count > 0 then @onChapterIndexChanged(@scope.chapter)

    hasMoreResults: => @getAt(@scope.chapter + 1)?

    getAt: (index)=>
        return unless index?
        chapter_id = _.keys(@Results.list)[index]
        @Results.get(chapter_id) or {}

    onChapterIndexChanged: (newIndex)=>
        chapter = @getAt newIndex
        @scope.safeApply =>
            @scope.results = chapter


angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
