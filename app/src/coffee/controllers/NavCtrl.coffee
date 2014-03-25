class NavCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?     
# EOF
