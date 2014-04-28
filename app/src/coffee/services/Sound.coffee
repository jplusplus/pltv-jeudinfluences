angular.module("spin.service").factory "Sound", ['User', 'Plot', '$rootScope', '$filter', (User, Plot, $rootScope, $filter)->
    new class Sound
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        startSoundTrack: (tracks) =>
            if @soundtrack?
                do @soundtrack.stop
                @soundtrack = undefined
            # Create the new sound
            @soundtrack = new Howl
                urls : tracks
                loop : yes
                buffer : yes
                volume : 0
                # Default states
                onplay : => $rootScope.safeApply => @soundtrack.isPlaying = yes
                onpause: => $rootScope.safeApply => @soundtrack.isPlaying = no
                onend  : => $rootScope.safeApply => @soundtrack.isPlaying = no
            # Play the sound with a fadein entrance
            @soundtrack.play => @soundtrack.fade(0, User.volume, 1000)

        startScene: (chapter=User.chapter, scene=User.scene)=>
            if @notificationtrack?
                do @notificationtrack.stop
                @notificationtrack = null
            if @voicetrack?
                do @voicetrack.stop
                @voicetrack = null
            # Start a new scene
            if scene? and Plot.chapters.length and Plot.scene(chapter, scene)?
                # Get scene object
                scene  = Plot.scene(chapter, scene)
                tracks = [ $filter('media')(scene.decor[0].soundtrack) ]
                # Update the soundtrack if it is different
                if scene.decor[0].hasOwnProperty 'soundtrack'
                    if scene.decor[0].soundtrack?
                        if (not @soundtrack?)
                            @startSoundTrack tracks
                        else if (not angular.equals( @soundtrack.urls(), tracks))
                            @soundtrack.fade User.volume, 0, 1000, =>
                                @startSoundTrack tracks
                    else if @soundtrack?
                        @soundtrack.fade (do @soundtrack.volume), 0, 1000, =>
                            do @soundtrack.stop
                            @soundtrack = undefined

        toggleSequence: (chapterIdx=User.chapter, sceneIdx=User.scene, sequenceIdx=User.sequence)=>
            if sequenceIdx?
                if @notificationtrack?
                    do @notificationtrack.stop
                    @notificationtrack = null
                if @voicetrack?
                    do @voicetrack.stop
                    @voicetrack = null
                if @soundtrack?
                    if (do @soundtrack.volume) < User.volume
                        @soundtrack.fade( (do @soundtrack.volume), User.volume, 500 )
                # Get sequence object
                sequence = Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
                # Sequence is a voicetrack
                if sequence? and sequence.type is "voixoff"
                    tracks = [$filter('media')(sequence.body or sequence.sound)]
                    # Update the voicetrack if it is different
                    if not @voicetrack? or not angular.equals( @voicetrack.urls(), tracks)
                        # Create the new sound
                        @voicetrack = new Howl
                            urls    : tracks
                            loop    : no
                            buffer  : yes
                            volume  : 0
                            autoplay: no
                            # Default states
                            onload  : =>
                                do @voicetrack.play
                            onplay  : =>
                                $rootScope.safeApply =>
                                    if @soundtrack?
                                        @soundtrack.fade( @soundtrack.volume(), User.volume/4, 500 )
                                        # Duration only on starting
                                        duration = if @soundtrack.pos() is 0 then 1000 else 0
                                    @voicetrack.fade(0, User.volume, duration)
                                    @voicetrack.isPlaying = yes
                                    @voicetrack._interval = setInterval ((context) =>
                                        context.voicetrack._position = context.voicetrack.pos() or 0
                                        return =>
                                            if context.voicetrack? and context.voicetrack.isPlaying
                                                $rootScope.safeApply =>
                                                    context.voicetrack._position = do context.voicetrack.pos
                                    )(@), 500
                            onpause : =>
                                $rootScope.safeApply =>
                                    @voicetrack.isPlaying = no
                            onend   : =>
                                $rootScope.safeApply =>
                                    @soundtrack.fade( @soundtrack.volume(), User.volume, 500 ) if @soundtrack?
                                    $rootScope.safeApply => @voicetrack._position = @voicetrack._duration
                                    @voicetrack.pos(0)
                                    @voicetrack.isPlaying = no
                                    clearInterval @voicetrack._interval
                                    do User.nextSequence
                    # Just play the voice
                    else if @voicetrack? and not @voicetrack.isPlaying
                        do @voicetrack.play
                    # Pause sound
                    else if @voicetrack? and @voicetrack.isPlaying?
                        do @voicetrack.pause
                else
                    if @voicetrack?
                        do @voicetrack.stop
                        @voicetrack = null
                    if sequence? and sequence.type is "notification"
                        tracks = [$filter('media')(sequence.sound)]
                        @notificationtrack = new Howl
                            urls : tracks
                            loop : no
                            buffer : yes
                            volume : User.volume
                            autoplay : yes
                            onplay : =>
                                $rootScope.safeApply =>
                                    @notificationtrack.isPlaying = yes
                            onpause : =>
                                $rootScope.safeApply =>
                                    @notificationtrack.isPlaying = no
                            onend : =>
                                $rootScope.safeApply =>
                                    @notificationtrack.isPlaying = no

        toggleVoicetrack: =>
            if @voicetrack?
                if @voicetrack.isPlaying
                    do @voicetrack.pause
                    @voicetrack.isPlaying = no
                else
                    do @voicetrack.play
                    @voicetrack.isPlaying = yes

        stopTracks: (stopVoice=yes, stopSound=yes)=>
            if stopVoice and @voicetrack?
                do @voicetrack.stop
            if stopSound and @soundtrack?
                do @soundtrack.stop

        updateVolume: (volume)=>
            # New volume set
            if volume?
                if @soundtrack?
                    @soundtrack.volume(volume)

]
# EOF
