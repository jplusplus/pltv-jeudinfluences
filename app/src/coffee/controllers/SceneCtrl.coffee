class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User', 'Sound', 'Timeout', 'constant.characters']

    constructor: (@scope, @Plot, @User, @Sound, @Timeout, characters) ->
        @scope.plot  = @Plot
        @scope.user  = @User         
        @scope.sound = @Sound
        @scope.timeout = @Timeout
        # Establishes a bound between "src" and "chapter" arguments
        # provided by the scene directive and the Countroller
        @scene = @scope.scene = @scope.src              
        @chapter = @scope.chapter
        # True if the given scene is visible
        @shouldShowScene = @scope.shouldShowScene = => 
            @scene.id is @User.scene or
            @User.isSummary and @isLastScene()

        @isLastScene = =>
            @scene.id is @User.lastScene and @chapter.id is @User.lastChapter
        
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=>   
            @shouldShowScene()            and
            # Hide the sequence is the user in one of this states
            not @User.isStartingChapter() and
            not @User.isGameOver          and
            not @User.isGameDone          and
            not @User.isSummary           and
            # And show the sequence if it is the last one with a next button
            [ @getLastDialogIdx(), @User.sequence ].indexOf(idx) > -1

        # Just wraps the function from the user service
        @scope.goToNextSequence = => do @User.nextSequence 

        # Select an option within a sequence by wrappeing the User's method       
        @scope.selectOption = (option, idx)=>      
            # Save choice for this scene
            @User.updateCareer choice: idx, scene: @User.pos()
            # Some choice may have an outro feedback
            if option.outro?
                # Find the current scene
                scene = @Plot.scene @User.chapter, @User.scene                
                # Create a "virtual sequence" at the end of the scene
                # (becasue every choice is at the end of a scene)
                virt_sequence = 
                    type      : "feedback"
                    body      : option.outro
                    next_scene: option.next_scene

                scene.sequence.push @Plot.wrapSequence virt_sequence
                # Then go the next sequence
                @scope.goToNextSequence()
                
        # Get the list of the background for the given scene
        @scope.getSceneBgs = =>
            # Cache bgs to avoid infinite digest iteration
            return @bgs if @bgs?
            return [] if (not @scene? or not @scene.decor)
            # First background is the one from the scene      
            @bgs = [src: @scene.decor[0].background, sequence: -1]
            # Look into each scene's sequence to find the new background
            for sequence, idx  in @scene.sequence                                
                # Add the bg to bg list
                @bgs.push src: sequence.body, sequence: idx if sequence.isNewBg()
            @bgs
        # True if we should display the given bg
        @scope.shouldDisplayBg = (bg)=>
            should_display = no
            # Ids of every sequences            
            for id in _.map(@bgs, (bg)-> bg.sequence)
                # Took the last higher id than the current sequence
                higherId = id if id <= @User.sequence
            should_display = bg.sequence is 0 or (bg.sequence is higherId)

            if not @User.isSummary
                should_display = should_display and @User.scene is @scene.id
            else
                should_display = should_display and @isLastScene()
            return should_display

        # Play or pause the soundtrack
        @scope.toggleVoicetrack = @Sound.toggleVoicetrack
        # Last dialog box that we see
        @getLastDialogIdx = @scope.getLastDialogIdx = =>
            # Get current indexes
            chapterIdx  = @User.chapter
            sceneIdx    = @User.scene
            sequenceIdx = @User.sequence
            while yes
                sequence = @Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
                break if sequenceIdx <= 0 or not sequence? or sequence.hasExit()
                sequenceIdx--         
            sequenceIdx

angular.module('spin.controller').controller("SceneCtrl", SceneCtrl)
# EOF