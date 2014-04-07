class ResultsCtrl
    @$inject: ['$scope', 'Progression', 'Plot', 'User']
    constructor: (@scope, @Progression, @Plot, @User)->                             
        @scope.plot  = @Plot
        @scope.user  = @User 
        @scope.shouldShowResults = -> no


angular.module('spin.controller').controller("ResultsCtrl", ResultsCtrl)    
# EOF
