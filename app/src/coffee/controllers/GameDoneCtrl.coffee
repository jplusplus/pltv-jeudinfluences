# GameDone controller is responsible to handle the ending
class GameDoneCtrl
    @$inject: ['$scope', 'User']

    constructor: (@scope, @User)->
        _.extend @scope, @

    shouldShowTheEnd: => @User.isGameDone 