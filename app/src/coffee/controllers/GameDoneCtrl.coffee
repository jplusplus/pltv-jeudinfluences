# GameDone controller is responsible to handle the ending
class GameDoneCtrl
    @$inject: ['$scope', 'User']

    constructor: (@scope, @User)->
        @scope.user = @User

        @scope.shouldShowTheEnd = @shouldShowTheEnd

    shouldShowTheEnd: => @User.isGameDone