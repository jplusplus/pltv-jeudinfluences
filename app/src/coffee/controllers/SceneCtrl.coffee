class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->       
        SEQUENCE_TYPE_WITH_NEXT = ["dialogue", "narrative", "video", "notification"]
        SEQUENCE_TYPE_BLOCKING  = ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
        SEQUENCE_TYPE_DIALOG    = ["dialogue", "narrative", "voixoff"]
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> 1*scene.id is @User.scene   
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=> 1*idx is @User.sequence
        # True if the sequence's button should be shown
        @scope.shouldShowNext = (sequence)=> SEQUENCE_TYPE_WITH_NEXT.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is visible into the dialog box
        @scope.isDialog = (sequence)=> SEQUENCE_TYPE_DIALOG.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is a choice
        @scope.isChoice = (sequence)=> sequence.type.toLowerCase() is "choice"
        # Just wraps the function from the user service
        @scope.goToNextSequence = @User.nextSequence        
# EOF
