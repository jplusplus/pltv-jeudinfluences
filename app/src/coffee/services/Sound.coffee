angular.module("spin.service").factory "Sound", ['User', 'Plot', '$rootScope', '$filter', (User, Plot, $rootScope, $filter)->
    new class Sound
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────        
        startScene: (chapter=User.chapter, scene=User.scene)=>
            # Start a new scene
            if scene? and Plot.chapters.length and Plot.scene(chapter, scene)?
                # Get scene object
                scene  = Plot.scene(chapter, scene)                 
                tracks = [ $filter('media')(scene.decor[0].soundtrack) ]
                # Update the soundtrack if it is different
                if not @soundtrack? or not angular.equals( @soundtrack.urls(), tracks)
                    # Create the new sound
                    @soundtrack = new Howl
                        urls   : tracks                    
                        loop   : yes
                        buffer : yes
                        volume : 0
                        # Default states
                        onplay : => $rootScope.safeApply => @soundtrack.isPlaying = yes
                        onpause: => $rootScope.safeApply => @soundtrack.isPlaying = no
                        onend  : => $rootScope.safeApply => @soundtrack.isPlaying = no
                    # Play the sound with a fadein entrance
                    @soundtrack.play => @soundtrack.fade(0, User.volume, 1000)


        toggleSequence: (chapterIdx=User.chapter, sceneIdx=User.scene, sequenceIdx=User.sequence)=>            
            if sequenceIdx?
                # Get sequence object
                sequence = Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)                     
                # Sequence is a voicetrack
                if sequence? and sequence.type is "voixoff"
                    tracks = [$filter('media')(sequence.body)]
                    # Update the voicetrack if it is different
                    if not @voicetrack? or not angular.equals( @voicetrack.urls(), tracks)
                        # Create the new sound
                        @voicetrack = new Howl
                            urls    : tracks                    
                            loop    : no
                            buffer  : yes
                            volume  : 0
                            autoplay: yes
                            # Default states
                            onplay  : => 
                                $rootScope.safeApply => 
                                    @soundtrack.fade( @soundtrack.volume(), User.volume/2 ) if @soundtrack?
                                    # Duration only on starting
                                    duration = if @soundtrack.pos() is 0 then 1000 else 0
                                    @voicetrack.fade(0, User.volume, duration)                                     
                                    @voicetrack.isPlaying = yes
                            onpause : => 
                                $rootScope.safeApply => 
                                    @voicetrack.isPlaying = no
                            onend   : => 
                                $rootScope.safeApply => 
                                    @soundtrack.fade( @soundtrack.volume(), User.volume ) if @soundtrack?
                                    @voicetrack.pos(0)
                                    @voicetrack.isPlaying = no
                    # Just play the voice
                    else if @voicetrack? and not @voicetrack.isPlaying 
                        do @voicetrack.play
                    # Pause sound
                    else if @voicetrack? and @voicetrack.isPlaying?                        
                        do @voicetrack.pause
                else
                    do @voicetrack.stop()

        updateVolume: (volume)=>                      
            # New volume set
            if volume?                    
                switch yes
                    when @voicetrack? and @soundtrack?                            
                        @voicetrack.volume(volume)        
                        @soundtrack.volume(volume/2)                           
                    when @voicetrack?                           
                        @voicetrack.volume(volume)        
                    when @soundtrack?                           
                        @soundtrack.volume(volume)     

]
# EOF