angular.module("spin.service").factory "Timeout", [
    '$rootScope'
    'User'
    'Plot'
    'constant.settings'
    '$timeout'
    ($rootScope, User, Plot, settings, $timeout)->
        new class Timeout
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                @_step = 0
                @remainingTime = 0

            toggleSequence: (chapterIdx=User.chapter, sceneIdx=User.scene, sequenceIdx=User.sequence) =>
                if sequenceIdx?
                    @sequence = Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
                    return if not @sequence?          
                    # Some choices have a delay           
                    if @sequence.type is 'choice' and @sequence.delay?
                        @remainingTime = 0
                        @_step = settings.timeoutRefRate * 100 / (@sequence.delay * 1000)
                        $timeout @timeStep, settings.timeoutRefRate
                    # Some sequence are feedbacks that disapear after a short delay
                    else if @sequence.type is 'feedback'                        
                        # Simply go to the next sequence after a short delay
                        $timeout(
                            # Closure to pass the current sequence object
                            do (sequence=@sequence)->
                                # Simply go to the next scene
                                -> User.goToScene(sequence.next_scene)                            
                        , settings.feedbackDuration)

            timeStep: =>
                @remainingTime += @_step
                if @remainingTime < 100
                    $timeout @timeStep, settings.timeoutRefRate
                else
                    _default = @sequence.default_option or 0
                    option = @sequence.options[_default]
                    @remainingTime = 0
                    @_step = 0
                    User.updateCareer choice: _default, scene: User.pos()
                    User.goToScene option.next_scene

]
# EOF