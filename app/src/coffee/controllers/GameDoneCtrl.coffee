# GameDone controller is responsible to handle the ending
class GameDoneCtrl
    @$inject: ['$scope', '$http' , 'constant.api', 'User']

    constructor: (@scope, @http, @api, @User)->
        @scope.user = @User

        @scope.shouldShowTheEnd = @shouldShowTheEnd

        @scope.gameDoneSentence = @gameDoneSentence

        @scope.$watch 'user.isGameDone', @getResults

        @scope.isInnocent = => @User.indicators.guilt < 50

        @scope.isHonnest  = => @User.indicators.honesty >= 50 

        @scope.isMurderer = => @User.indicators.meurtre?

    shouldShowTheEnd: => @User.isGameDone

    getResults: =>
        url = "#{@api.finalSummary}?token=#{@User.token}"
        @http.get(url).then (data)=>
            @scope.results = data.data