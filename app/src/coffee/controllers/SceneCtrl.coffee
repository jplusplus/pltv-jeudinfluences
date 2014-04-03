class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User', 'Sound', 'constant.characters', 'constant.settings']
    constructor: (@scope, @Plot, @User, @Sound, characters, settings) ->    
        @scope.sound = @Sound                                   
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> scene.id is @User.scene   
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=> [ @getLastDialogIdx(), @User.sequence ].indexOf(idx) > -1
        # True if the sequence's button should be shown
        @scope.shouldShowNext = (sequence)=> settings.sequence_with_next.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is visible into the dialog box
        @isDialog = @scope.isDialog = (sequence)=> settings.sequence_dialog.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is a choice
        @isChoice = @scope.isChoice = (sequence)=> sequence.type.toLowerCase() is "choice"                
        # True if the sequence is a voixoff
        @isPlayer = @scope.isPlayer = (sequence)=> sequence.type.toLowerCase() is "voixoff"             
         # True if the sequence is a new_background
        @isNewBg  = @scope.isNewBg  = (sequence)=> sequence.type.toLowerCase() is "new_background"        
        # True if the sequence is a notification
        @isNotification = @scope.isNotification= (sequence)=> sequence.type.toLowerCase() is "notification"        
        # Just wraps the function from the user service
        @scope.goToNextSequence = =>
            sequence = do @User.nextSequence       
            # Should we skip this new sequence?
            do @scope.goToNextSequence if sequence and settings.sequence_skip.indexOf( sequence.type.toLowerCase() ) > -1
        # Select an option within a sequence by wrappeing the User's method       
        @scope.selectOption = (option, idx)=>      
            # Save choice for this scene
            @User.updateCareer choice: idx, scene: @User.pos()
            # Go to the next scene
            @User.goToScene option.next_scene
        # Get the head of this character
        @scope.getHeadSrc = (sequence)=>            
            if sequence.character?                
                # slugify the character name (to avoir error)
                character = sequence.character.toLowerCase().replace(/[^\w-]+/g,'')                
                # Just returns the URL
                characters[character]     
        # Get the list of the background for the given scene
        @scope.getSceneBgs = (scene)=>
            # Cache bgs to avoid infinite digest iteration
            return @bgs if @bgs?
            # First background is the one from the scene      
            @bgs = [src: scene.decor[0].background, sequence: -1]
            # Look into each scene's sequence to find the new background
            for sequence, idx  in scene.sequence                                
                # Add the bg to bg list
                @bgs.push src: sequence.body, sequence: idx if @isNewBg sequence            
            @bgs
        # True if we should display the given bg
        @scope.shouldDisplayBg = (bg)=>
            # Ids of every sequences            
            for id in _.map(@bgs, (bg)-> bg.sequence)
                # Took the last higher id than the current sequence
                higherId = id if id <= @User.sequence
            # Return the following assertion                        
            bg.sequence is higherId
        # Play of pause the soundtrack
        @scope.toggleVoicetrack = @Sound.toggleSequence
        # Last dialog box that we seen
        @getLastDialogIdx = @scope.getLastDialogIdx = =>                    
            # Get current indexes
            chapterIdx  = @User.chapter
            sceneIdx    = @User.scene
            sequenceIdx = @User.sequence
            while yes
                sequence = @Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)                                  
                break if sequenceIdx <= 0 or not sequence? or @isPlayer(sequence) or @isDialog(sequence)
                sequenceIdx--            
            sequenceIdx




# EOF