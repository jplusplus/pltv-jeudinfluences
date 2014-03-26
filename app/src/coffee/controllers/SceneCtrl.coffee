class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->       
        SEQUENCE_TYPE_WITH_NEXT = ["dialogue", "narrative", "video", "notification"]
        SEQUENCE_TYPE_BLOCKING  = ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> 1*scene.id is @User.scene   
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=> 1*idx is @User.sequence
        # True if the sequence's button should be shown
        @scope.shouldShowNext = (sequence)=> yes or SEQUENCE_TYPE_WITH_NEXT.indexOf( sequence.type.toLowerCase() ) > -1
        # Just wraps the function from the user service
        @scope.goToNextSequence = @User.nextSequence
# EOF
