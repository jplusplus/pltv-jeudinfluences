class MainCtrl
    @$inject: ['$scope', 'Progression', 'Plot', 'User', 'Sound']
    constructor: (@scope, @Progression, @Plot, @User, @Sound)->                             
        @scope.plot  = @Plot
        @scope.user  = @User 
        @scope.sound = @Sound 


angular.module('spin.controller').controller("MainCtrl", MainCtrl)    
# EOF
