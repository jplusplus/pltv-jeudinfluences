angular.module('spin.service').service 'Xiti', ['$rootScope', 'User', 'Plot', 'constant.xiti', ($rootScope, User, Plot, xiti)->
    new class Xiti
        constructor:->     
            do @updateConfig
            # Chapter change in game
            @watchInGame (->[User.inGame, User.chapter]), => @loadPage @chapter()
            # Scene change in game
            @watchInGame (->[User.inGame, User.scene]), => @loadPage @chapter()
            # Sequence change in game
            @watchInGame (->[User.inGame, User.sequence]), => @loadPage @chapter(), @scene(), @sequence()
            # Game states
            @watchIf (->User.isGameOver), ((v)->v), => @loadPage "game-over"                     
            @watchIf (->User.isGameDone), ((v)->v), => @loadPage "bilan-fin-jeu"                 
            @watchIf (->User.isSummary) , ((v)->v), => @loadPage @chapter(), "bilan-fin-chapitre"

        # Watch "ev" and trigger "fn" only if the assert() is true
        watchIf    : (ev, assert, fn)=> $rootScope.$watch ev, ((v)=> fn() if assert(v) ), yes 
        # Watch "ev" and trigger "fn" only if User.ingame is true
        watchInGame: (ev, fn)=> @watchIf ev, (->User.inGame), fn
        # Token getter for user position
        chapter    : -> "chapter-n#{User.chapter}"
        scene      : -> "scene-n#{User.scene}"
        sequence   : ->
            # Get the sequence to know its type
            sequence = Plot.sequence User.chapter, User.scene, User.sequence
            # Choice type doesn't not have an id
            if sequence and sequence.isChoice() then "choice" else "sequence-n#{User.sequence}"


        updateConfig: =>
            # Xiti's core variables
            window.xtsd   ?= xiti.xtsd
            window.xtsite ?= xiti.xtsite # site number
            window.xtn2   ?= xiti.xtn2   # level 2 site            
            window.xtpage ?= "home"      # page name (with the use of :: to create chapters)
            window.xtdi   ?= ""          # implication degree        

        loadPage: =>  
            # Convert arguments object to an array
            args = Array.prototype.slice.call(arguments)      
            # Current page must be different
            if @currentPage isnt args.join("::")
                # Record the current page slug to avoid declare the page twice
                @currentPage = args.join("::")
                # Create xtpage slug
                xtpage       = xiti.prefix + @currentPage
                # Destroy existing image
                angular.element( @img ).remove() if @img?
                # Create the new image
                @img        = document.createElement("img")
                @img.height = 1
                @img.width  = 1
                @img.src    = "#{window.xtsd}.xiti.com/"
                @img.src   += "hit.xiti?s=#{window.xtsite}"
                @img.src   += "&s2=#{xtn2}"
                @img.src   += "&p=#{xtpage}"
                @img.src   += "&di=#{window.xtdi}"
                @img.src   += "&na=#{(new Date).getTime()}"            
                # Appends the image to the body
                angular.element("body").append @img

        track: (ev, name, destination='C', type='N', level=window.xtn2)->    
            # "destination" can be:
            #    F -> page
            #    C -> click
            # "type" can be:
            #    N -> navigation 
            #    S -> exit
            #    A -> action 
            #    T -> download        
            window.xt_click(ev.target ? null, destination, level, name, type)
            yes 
]