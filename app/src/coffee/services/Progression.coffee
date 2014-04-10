angular.module("spin.service").factory "Progression", [
    '$rootScope'
    'Plot'
    'User'
    'Sound'
    'Timeout'
    ($rootScope, Plot, User, Sound, Timeout)->
        new class Progression    
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->           
                # Record begining date of a chapter
                $rootScope.$watch (=>[User.chapter, User.inGame]), User.saveChapterChanging, yes
                # Update local storage
                $rootScope.$watch (=>User), User.updateLocalStorage, yes                    
                # Scene is changing
                $rootScope.$watch (=> Plot.chapters.length + User.scene.length), (-> do Sound.startScene), yes
                # Sequence is changing
                $rootScope.$watch (=>User.sequence), ->                                    
                    do Sound.toggleSequence
                    do Timeout.toggleSequence
                # Update the volume
                $rootScope.$watch (=>User.volume), Sound.updateVolume
]
# EOF