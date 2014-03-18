class MainCtrl
    @$inject: ['$scope', 'Plot']
    constructor: (@scope, @Plot) ->     
        @scope.plot = @plot = do @Plot.get      
# EOF
