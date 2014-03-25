angular.module("spin.service").factory "Sound", ['User', 'Plot', '$rootScope', (User, Plot, $rootScope)->
    new class Sound
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: ->
            $rootScope.$watch (-> Plot.chapters or User.scene ), =>    
                # Start a new scene
                if User.scene? and Plot.chapters.length   
                    scene = Plot.scene(User.chapter, User.scene)         
                    # Create the new sound
                    @soundtrack = new Howl(
                        urls: [ scene.decor[0].soundtrack ]                      
                        loop: yes
                        buffer: yes
                        volume: 0
                    )
                    # Play the sound with a fadein entrance
                    @soundtrack.play => @soundtrack.fade(0, User.volume, 10000)


            $rootScope.$watch (-> Plot.chapters or User.sequence ), =>  
                console.log @soundtrack

]
# EOF