class NavCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->
        @scope.user   = @User
        @scope.volume = @User.volume * 100
        # Udate the User volume according the scope attribute
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?
# EOF
