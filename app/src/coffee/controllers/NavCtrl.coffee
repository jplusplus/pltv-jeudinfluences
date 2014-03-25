class NavCtrl
    @$inject: ['$scope', 'User']
    constructor: (@scope, @User) ->
        # Udate the User volume according the scope attribute
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?
# EOF
