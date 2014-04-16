angular.module("spin.service").factory "Progression", [
    '$rootScope'
    'Plot'
    'User'
    'Sound'
    'Timeout'
    'Xiti'
    ($rootScope, Plot, User, Sound, Timeout)->
        new class Progression    
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                # Record begining date of a chapter
                $rootScope.$watch (=>User.inGame), User.saveChapterChanging, yes                
                $rootScope.$watch (=>User.chapter), @onChapterChanged, yes
                # Update local storage
                $rootScope.$watch (=>User), User.updateLocalStorage, yes                    
                # Scene is changing
                $rootScope.$watch (=> [Plot.chapters, User.scene] ), (-> do Sound.startScene), yes
                # Sequence is changing
                $rootScope.$watch (=>User.sequence), ->
                    do Timeout.toggleSequence 
                    do Sound.toggleSequence   
                # Update the volume
                $rootScope.$watch (=>User.volume), Sound.updateVolume

            onChapterChanged: (newId, oldId)->
                # User.isSummary will trigger the chapter results summary 
                # showing if set to true
                old_chapter = Plot.chapter oldId
                if old_chapter and old_chapter.bilan
                    User.isSummary = true
                else 
                    User.saveChapterChanging newId
                User.lastChapter = oldId


]
# EOF