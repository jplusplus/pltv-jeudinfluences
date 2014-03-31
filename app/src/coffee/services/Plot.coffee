angular.module("spin.service").factory "Plot", ['$http', 'constant.api', ($http, api)->
    new class Plot    
        # ──────────────────────────────────────────────────────────────────────────
        # Public method
        # ──────────────────────────────────────────────────────────────────────────
        constructor: ->
            @chapters = []
            # Get plot
            $http.get(api.plot).success (chapters)=> @chapters = chapters
            return @           
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