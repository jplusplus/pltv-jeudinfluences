angular.module("spin.service").factory "Plot", [
        '$http'
        'constant.api'
        'constant.settings'
        'constant.characters'
        'constant.types'
        ($http, api, settings, characters, types)->
            new class Plot
                sequenceWrappingObject:
                    # help us to know if we already wrapped a sequence
                    _wrapped: yes 

                    lowerType: -> this.type.toLowerCase()

                    isDialog: ->
                        settings.sequenceDialog.indexOf( this.lowerType() ) > -1

                    isSkipped: ->
                        settings.sequenceSkip.indexOf( this.lowerType() ) > -1

                    isChoice: ->
                        this.lowerType() is types.sequence.choice

                    isPlayer: ->
                        this.lowerType() is types.sequence.player

                    isVideo: ->
                        this.lowerType() is types.sequence.video

                    isNewBg: ->
                        this.lowerType() is types.sequence.newBackground

                    isGameOver: ->
                        this.lowerType() is types.sequence.gameOver

                    isNotification: ->
                        this.lowerType() is types.sequence.notification

                    isFeedback: ->
                        this.lowerType() is types.sequence.feedback

                    hasNext: ->  
                        settings.sequenceWithNext.indexOf( this.lowerType() ) > -1 

                    hasExit: ->
                        this.isPlayer() or 
                        this.isDialog() or 
                        this.isChoice() or 
                        this.isFeedback()

                    getHeadSrc: ->
                        if this.character?
                            # slugify the character name (to avoir error)
                            character = this.character.toLowerCase().replace(/[^\w-]+/g,'')
                            # Just returns the URL
                            characters[character]    

                # ─────────────────────────────────────────────────────────────────
                # Public methods
                # ─────────────────────────────────────────────────────────────────
                constructor: ->
                    @chapters = []
                    # Get plot
                    $http.get(api.plot).success (chapters)=> @chapters = @wrapChapters chapters
                    return @

                wrapSequence: (sequence)=>
                    sequence = sequence or { type: "" }
                    unless sequence._wrapped
                        sequence = _.extend sequence, @sequenceWrappingObject
                    sequence

                wrapChapters: (chapters)=>
                    for c in chapters
                        for s in c.scenes
                            s.sequence = _.map s.sequence, @wrapSequence
                    chapters

                # Getter shortcuts
                chapter : (chapterId)=> 
                    # Fetch the chapters list
                    _.find @chapters or [], (chapter)-> chapter.id is chapterId   

                scene   : (chapterId, sceneId)=>
                    chapter = @chapter(chapterId) or {}                  
                    # Fetch the chapters list and its scenes
                    _.find chapter.scenes or [], (scene)-> scene.id is sceneId

                sequence: (chapterId, sceneId, sequenceIdx)=>                         
                    # Find a scene, inside a chapter, then takes the given element
                    scene = @scene(chapterId, sceneId) or { sequence: [] }
                    scene.sequence[sequenceIdx]

]
# EOF