angular.module("spin.service").factory "Progression", [
    '$rootScope'
    '$timeout'
    'constant.keys'
    'constant.doors'
    'Plot'
    'User'
    'Sound'
    'Timeout'
    'KeyboardCommands'
    ($rootScope, $timeout, keys, doors, Plot, User, Sound, Timeout, KeyboardCommands)->
        new class Progression    
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                $rootScope.$watch (=>User.inGame),  @onInGameChanged,  yes                
                $rootScope.$watch (=>User.chapter), @onChapterChanged, yes
                $rootScope.$watch (=>User.scene),   @onSceneChanged,   yes
                $rootScope.$watch (=>User.isReady), User.saveChapterChanging, yes
                # Update local storage
                $rootScope.$watch (=>User), User.updateLocalStorage, yes                    
                # Scene is changing
                $rootScope.$watch (=> [Plot.chapters, User.scene] ), (->
                    do Sound.startScene
                ), yes
                # Sequence is changing
                $rootScope.$watch (=>(User.scene+User.sequence)), ->
                    do Timeout.toggleSequence 
                    do Sound.toggleSequence

                $rootScope.$watch (=>do User.isStartingChapter), ->
                    do Sound.toggleSequence

                # Update the volume
                $rootScope.$watch (=>User.volume), Sound.updateVolume

                $rootScope.$watch (=>User.isGameDone),  @singMeTheEnd,  yes                


                # keyboard commands parametering 
                KeyboardCommands.register keys.next, @onKeyPressed


            onChapterChanged: (newId, oldId)->
                i = (v)-> parseInt v # little alias to parseInt
                should_show_summary = false
                new_chapter = Plot.chapter newId 
                old_chapter = Plot.chapter oldId

                # results are show in a single way (when moving forward in
                # the story) so we check user is going in the good way
                should_show_summary = newId > oldId and
                                      old_chapter and old_chapter.bilan

                if should_show_summary
                    # User.isSummary will trigger the chapter results summary 
                    # showing if set to true
                    User.isSummary = true
                else 
                    User.saveChapterChanging newId

                User.lastChapter = oldId

            onSceneChanged: (newScene, oldScene)=>
                User.lastScene = oldScene

            onInGameChanged: =>
                # special treatment for triggering end of the game, we need to 
                # trigger sound ending (only for voices)
                if User.isGameDone
                    Sound.stopTracks yes, no
                else
                    # Record begining date of a chapter
                    User.saveChapterChanging true 

            onKeyPressed: (e)=>
                if User.inGame
                    seq = Plot.sequence(User.chapter, User.scene, User.sequence)
                    if seq.hasNext()
                        do User.nextSequence


            singMeTheEnd: (done) =>
                return unless console? and console
                if done
                    i = 0
                    for sentence in doors.theEnd
                        lapse = 3500 * i
                        $timeout(do(phrase=sentence)->
                            -> console.log phrase
                        , lapse)
                        i++



]
# EOF