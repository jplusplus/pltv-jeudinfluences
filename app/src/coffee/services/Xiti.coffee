angular.module('spin.service').service 'Xiti', ['$rootScope', 'User', 'Plot', ($rootScope, User, Plot)->
    new class Xiti
        config:
            xtsd  : "http://logc238"
            xtsite: "475907"
            xtn2  : "65"
            prefix: ""


        constructor:->     
            do @updateConfig
            # Record homepage (default page for everyone)
            @loadPage "home"
            # Wait for game to start
            @start = no
            # Chapter change
            @watchInGame (->[User.inGame, User.chapter]), => @loadPage @chapter()
            # Scene change
            @watchInGame (->[User.inGame, User.scene]), => @loadPage @chapter()
            # Sequence change
            @watchInGame (->[User.inGame, User.sequence]), => @loadPage @chapter(), @scene(), @sequence()
            # Game states
            $rootScope.$watch (->User.isGameOver), ( (s)=> @loadPage "game-over"                        if s ), yes
            $rootScope.$watch (->User.isGameDone), ( (s)=> @loadPage "bilan-fin-jeu"                    if s ), yes
            $rootScope.$watch (->User.isSummary) , ( (s)=> @loadPage @chapter(), "bilan-fin-chapitre-n" if s ), yes

        # Watcher only "ingame"
        watchInGame: (ev, fn)-> $rootScope.$watch ev, (=> fn() if User.inGame), yes
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
            window.xtsd     = @config.xtsd
            window.xtsite   = @config.xtsite # site number
            window.xtn2     = @config.xtn2   # level 2 site            
            window.xtpage   = "default"      # page name (with the use of :: to create chapters)
            window.xtdi     = ""             # implication degree
            window.xt_multc = ""             # customized indicators
            window.xt_an    = ""             # numeric identifier
            window.xt_ac    = ""             # category

            window.xtparam = "" unless window.xtparam?
            window.xtparam += "&ac=" + xt_ac + "&an=" + xt_an + xt_multc            

        loadPage: =>  
            # Convert arguments object to an array
            args = Array.prototype.slice.call(arguments)      
            # Current page must be different
            if @currentPage isnt args.join("::")
                # Record the current page slug to avoid declare the page twice
                @currentPage = args.join("::")
                console.log @currentPage
                return
                # Create xtpage slug
                xtpage       = @config.prefix + @currentPage
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