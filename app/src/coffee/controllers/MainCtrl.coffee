class MainCtrl
    @$inject: ['$scope', 'Plot', 'User', 'Sound']
    constructor: (@scope, @Plot, @User, @Sound) ->                     
        @scope.plot  = @Plot
        @scope.user  = @User 
        @scope.sound = @Sound 
        
# EOF
