angular.module("spin.service").factory "Sound", ['User', 'Plot', '$rootScope', '$filter', (User, Plot, $rootScope, $filter)->
    new class Sound
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: ->
            # Scene is changing
            $rootScope.$watch (-> Plot.chapters or User.scene ), => do @startScene    
            # Sequence is changing
            $rootScope.$watch (-> User.sequence ), => do @startSequence   
            # Update the volume
            $rootScope.$watch (-> User.volume ), @updateVolume   

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
                        urls  : tracks                    
                        loop  : yes
                        buffer: yes
                        volume: 0
                    # Play the sound with a fadein entrance
                    @soundtrack.play => @soundtrack.fade(0, User.volume, 1000)

        startSequence: (chapter=User.chapter, scene=User.scene, sequence=User.sequence)=>            
            if sequence?
                # Get sequence object
                sequence = Plot.sequence(chapter, scene, sequence)                     
                # Sequence is a voicetrack
                if sequence? and sequence.type is "voixoff"
                    tracks = [$filter('media')(sequence.body)]
                    # Update the voicetrack if it is different
                    if not @voicetrack? or not angular.equals( @voicetrack.urls(), tracks)
                        # Create the new sound
                        @voicetrack = new Howl
                            urls: tracks                    
                            loop: no
                            buffer: yes
                            volume: 0
                        @soundtrack.fade( @soundtrack.volume(), User.volume/2 ) if @soundtrack?
                        # Play the sound with a fadein entrance
                        @voicetrack.play => @voicetrack.fade(0, User.volume, 1000)
                # Stop sound
                else if @voicetrack?
                    @soundtrack.fade( @soundtrack.volume(), User.volume ) if @soundtrack?
                    # Play the sound with a fadein entrance
                    @voicetrack.fade @voicetrack.volume(), 0, 1000, => @voicetrack.stop()

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