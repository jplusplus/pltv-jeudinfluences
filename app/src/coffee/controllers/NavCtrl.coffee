class NavCtrl
    @$inject: ['$scope', 'User', 'ThirdParty']
    constructor: (@scope, @User, @ThirdParty) ->
        @scope.user       = @User
        @scope.thirdParty = @ThirdParty
        @scope.volume     = @User.volume * 10
        # True if the volume is on
        @scope.isVolumeOn = => @User.volume > 0
        # Udate the User volume according the scope attribute
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?    

        @scope.save = @save

    save: =>
        do @User.associate

angular.module('spin.controller').controller("NavCtrl", NavCtrl)
# EOF
