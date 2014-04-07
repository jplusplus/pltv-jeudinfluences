class ResultsCtrl
    @$inject: ['$scope', 'Progression', 'Plot', 'User']
    constructor: (@scope, @Progression, @Plot, @User)->                             
        @scope.plot  = @Plot
        @scope.user  = @User 
        @scope.shouldShowResults = => @User.isGameDone


angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
