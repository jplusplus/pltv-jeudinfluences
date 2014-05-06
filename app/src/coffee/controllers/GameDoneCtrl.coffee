# GameDone controller is responsible to handle the ending
class GameDoneCtrl
    @$inject: ['$scope', '$http' , 'constant.api', 'User', 'ThirdParty']

    constructor: (@scope, @http, @api, @User, @ThirdParty)->
        @scope.user = @User

        @scope.thirdParty = @ThirdParty

        @scope.shouldShowTheEnd = @shouldShowTheEnd

        @scope.gameDoneSentence = @gameDoneSentence

        @scope.$watch 'user.isGameDone', @getResults

        @scope.isInnocent = => @User.indicators.guilt < 50
        @scope.isGuilty   = => not @scope.isInnocent()

        @scope.isHonest   = => @User.indicators.honesty >= 50 
        @scope.isLier     = => not @scope.isHonest()



        @scope.isMurderer = => @User.indicators.meurtre?

    shouldShowTheEnd: => @User.isGameDone

    getResults: =>
        url = "#{@api.finalSummary}?token=#{@User.token}"
        @http.get(url).then (data)=>
            @scope.results = data.data