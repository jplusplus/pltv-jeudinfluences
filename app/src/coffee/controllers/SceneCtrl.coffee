class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User']
    constructor: (@scope, @Plot, @User) ->       
        SEQUENCE_TYPE_WITH_NEXT = ["dialogue", "narrative", "video", "notification"]
        SEQUENCE_TYPE_BLOCKING  = ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
        SEQUENCE_TYPE_DIALOG    = ["dialogue", "narrative", "voixoff"]
        # Just wraps the function from the user service
        @scope.goToNextSequence = @User.nextSequence       
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> scene.id is @User.scene   
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=> [ @getLastDialogIdx(), @User.sequence ].indexOf(idx) > -1
        # True if the sequence's button should be shown
        @scope.shouldShowNext = (sequence)=> yes or SEQUENCE_TYPE_WITH_NEXT.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is visible into the dialog box
        @isDialog = @scope.isDialog = (sequence)=> SEQUENCE_TYPE_DIALOG.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is a choice
        @isChoice = @scope.isChoice = (sequence)=> sequence.type.toLowerCase() is "choice"        
        # Select an option within a sequence by wrappeing the User's method       
        @scope.selectOption = (option)=> @User.goToScene option.next_scene


    getLastDialogIdx: =>        
        # Get current indexes
        chapterIdx  = @User.chapter
        sceneIdx    = @User.scene
        sequenceIdx = @User.sequence
        while yes
            sequence = @Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
            break if not sequence? or sequence < 0 or @isDialog sequence
            sequenceIdx--
        sequenceIdx

# EOF