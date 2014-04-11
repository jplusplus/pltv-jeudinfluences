class ResultsCtrl
    @$inject: ['$scope', '$sce', 'Progression', 'User', 'Plot', 'Results']

    STARTS_WITH_CAPITAL: /^[A-Z]/

    constructor: (@scope, @sce, @Progression, @User,  @Plot,  @Results)->
        # scope variable binding
        @scope.plot    = @Plot
        @scope.user    = @User
        @scope.chapter = 0
        
        # scope function binding
        @scope.shouldShowResults = => @User.isGameDone
        @scope.goNextChapter     = => @scope.chapter += 1
        @scope.userChoice = @userChoice
        @scope.hasMoreResults = @hasMoreResults

        # scope watches
        @scope.$watch 'chapter', @onChapterIndexChanged
        @scope.$watch =>
                _.keys(@Results.list).length
            , (results_count)=>
                if results_count > 0 then @onChapterIndexChanged(@scope.chapter)

    userChoice: (feedback)=>
        user_choice_idx = feedback.you if feedback.you?
        choice     = feedback.options[user_choice_idx]
        if choice?
            percentage = choice.percentage
            title      = choice.title
            title      = @unsentenceIt(title)
            result = 
                sentence:   @sce.trustAsHtml "Comme <b>#{percentage}%</b> des utilisateurs, #{title}"
                percentage: percentage
                percentage_style: 
                    width: "#{percentage}%"
            _.extend feedback, result

    hasMoreResults: => @getAt(@scope.chapter + 1)?

    unsentenceIt: (str)=> 
        # will remmove first capital letter of passed string if necessary
        if @STARTS_WITH_CAPITAL.test str  
            str  = str.replace str[0], str[0].toLowerCase()
        str

    getAt: (index)=>
        return unless index?
        chapter_id = _.keys(@Results.list)[index]
        @Results.get(chapter_id) or {}

    onChapterIndexChanged: (newIndex)=>
        chapter = @getAt newIndex
        @scope.safeApply =>
            console.log "chapter results: "
            @scope.results = chapter


angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
