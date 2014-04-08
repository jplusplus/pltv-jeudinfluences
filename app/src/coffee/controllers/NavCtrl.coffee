class NavCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->
        @scope.user   = @User
        @scope.volume = @User.volume * 10
        # True if the volume is on
        @scope.isVolumeOn = => @User.volume > 0
        # Udate the User volume according the scope attribute
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?    


angular.module('spin.controller').controller("NavCtrl", NavCtrl)
# EOF
