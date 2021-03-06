class ResultsCtrl
    @$inject: ['$scope', 'ThirdParty', 'Progression', 'User', 'Plot', 'Results']

    constructor: (@scope, @ThirdParty, @Progression, @User,  @Plot,  @Results)->
        # scope variable binding
        @scope.plot       = @Plot
        @scope.user       = @User
        @scope.thirdParty = @ThirdParty
        # scope function binding
        @scope.shouldShowResults  = @shouldShowResults 
        @scope.goNextChapter      = @goNextChapter
        @scope.hasPreviousResults = @hasPreviousResults
        @scope.previousResults    = @previousResults

        # scope watches
        @scope.$watch 'user.chapter', @onChapterChanged, yes

    goNextChapter: =>
        @scope.safeApply @User.leaveSummary
            
    shouldShowResults: => @User.isSummary and @User.inGame and not @User.isGameOver

    hasPreviousResults: => _.keys(@previousResults()).length > 0

    previousResults: => 
        if @scope.currentChapter?
            # it will look in the already loaded result list to see if there are 
            # some previous results or not
            _.filter @Results.list, (value, key) =>
                key < @scope.currentChapter.id

    onChapterChanged: (newId, oldId)=>
        chapter = @Plot.chapter oldId
        if chapter and chapter.bilan
            @scope.safeApply =>
                @scope.currentChapter  = chapter
                @Results.list = []
                do @Results.getPreviousResults
                @Results.get(chapter).then(
                        # success callback
                        (data)=>
                            @scope.currentResults = data
                    ,   ()=>
                            @User.isSummary = false
                            @scope.currentResults = undefined
                )



angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
