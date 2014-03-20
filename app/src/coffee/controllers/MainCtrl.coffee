class MainCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->                     
        @scope.plot = @Plot
        @scope.user = @User
        console.log @User.chapter        

# EOF
