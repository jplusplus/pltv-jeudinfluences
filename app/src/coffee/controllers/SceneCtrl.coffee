class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->  
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> scene.id is @User.scene        
# EOF
