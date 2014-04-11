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

    hasMoreResults: => _.isEmpty @getAt(@scope.chapter + 1)

    idAt: (index)=> _.keys(@Results.list)[index]

    getAt: (index)=>
        return unless index?
        @Results.get(@idAt index) or {}

    otherResults: => _.omit(@Results.list, @idAt @scope.chapter)

    onChapterIndexChanged: (newIndex)=>
        chapter = @getAt newIndex
        @scope.safeApply =>
            @scope.currentResults = chapter
            @scope.allOtherResults = @otherResults()


angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
