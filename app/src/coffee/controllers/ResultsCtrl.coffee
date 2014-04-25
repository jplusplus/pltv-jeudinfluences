class ResultsCtrl
    @$inject: ['$scope', 'Progression', 'User', 'Plot', 'Results']

    constructor: (@scope, @Progression, @User,  @Plot,  @Results)->
        # scope variable binding
        @scope.plot    = @Plot
        # scope function binding
        @scope.shouldShowResults  = @shouldShowResults 
        @scope.goNextChapter      = @goNextChapter
        @scope.hasPreviousResults = @hasPreviousResults
        @scope.previousResults    = @previousResults

        # scope watches
        @scope.$watch 'user.chapter', @onChapterChanged, yes

    goNextChapter: =>
        @scope.safeApply =>
            @User.isSummary = no
            @User.saveChapterChanging true

    shouldShowResults: => @User.isSummary and @User.inGame

    hasPreviousResults: => _.keys(@previousResults()).length > 0

    previousResults: => 
        if @scope.currentChapter?
            # it will look in the already loaded result list to see if there are 
            # some previous results or not
            _.omit @Results.list, @scope.currentChapter.id

    onChapterChanged: (newId, oldId)=>
        chapter = @Plot.chapter oldId
        if chapter and chapter.bilan
            @scope.safeApply =>
                @scope.currentChapter  = chapter
                @Results.get(chapter).then(
                        # success callback
                        (data)=> @scope.currentResults = data
                    ,   ()=>
                            @User.isSummary = false
                            @scope.currentResults = undefined
                )



angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
