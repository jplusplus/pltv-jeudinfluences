# GameDone controller is responsible to handle the ending
class GameDoneCtrl
    @$inject: ['$scope', '$http' , 'constant.api', 'User']

    constructor: (@scope, @http, @api, @User)->
        @scope.user = @User

        @scope.shouldShowTheEnd = @shouldShowTheEnd

        @scope.$watch 'user.isGameDone', @getResults

    shouldShowTheEnd: => @User.isGameDone

    getResults: =>
        url = "#{@api.finalSummary}?token=#{@User.token}"
        @http.get(url).then (data)=>
            @scope.results = data.data
