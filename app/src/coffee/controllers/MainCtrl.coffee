class MainCtrl
    @$inject: ['$scope', 'Progression', 'Plot', 'Sound', 'Xiti']

    constructor: (@scope, @Progression, @Plot, @Sound, @Xiti)->                             
        @scope.plot  = @Plot
        @scope.sound = @Sound     

angular.module('spin.controller').controller("MainCtrl", MainCtrl)    
# EOF
