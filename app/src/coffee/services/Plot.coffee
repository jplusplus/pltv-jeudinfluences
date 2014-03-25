angular.module("spin.service").factory "Plot", ['$http', ($http)->
    new class Plot    
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: ->
            @chapters = []
            # Get plot
            $http.get("/api/plot").success (chapters)=> @chapters = chapters
            return @           
        # Getter shortcuts
        chapter : (chapterId)=> 
            # Fetch the chapters list
            _.find @chapters or [], (chapter)-> 1*chapter.id is 1*chapterId                        
        scene   : (chapterId, sceneId)=>
            chapter = @chapter(chapterId) or {}            
            # Fetch the chapters list and its scenes
            _.find chapter.scenes or [], (scene)-> 1*scene.id is 1*sceneId
        sequence: (chapterId, sceneId, sequenceIdx)=>                         
            # Find a scene, inside a chapter, then takes the given element
            scene = @scene(chapterId, sceneId) or { sequence: [] }        
            scene.sequence[sequenceIdx]
]
# EOF