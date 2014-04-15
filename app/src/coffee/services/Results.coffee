angular.module("spin.service").factory("Results", [
    'User'
    'Plot'
    'constant.api' 
    '$q'
    '$rootScope'
    '$http'
    (User, Plot, api, $q, $rootScope, $http)->
        new class Results
            API_URL: api.results
            STARTS_WITH_CAPITAL: /^[A-Z]/
            constructor: ->
                @list = @list or {}
                # if we have a chapter > 1 on init it means its a returning user
                # and therefore we should check for all previous saw chapter 
                $rootScope.$watch (=> Plot.chapters.length), =>
                    if parseInt(User.chapter) > 1
                        @getPreviousResults()

            getPreviousResults: =>
                candidates  = _.filter Plot.chapters, (el)->
                    parseInt(el.id) < parseInt(User.chapter)
                # will load every candidate
                _.map candidates, @get


            get: (chapter)=>
                def = $q.defer()
                loaded = @list[chapter.id]
                if loaded?
                    # this defer & promise usage exists to keep consistency 
                    # with the result of this method (a promise)
                    def.resolve(loaded)
                else 
                    http_promise = $http.get @API_URL, { 
                        params: 
                            chapter: chapter.id
                            token: User.token
                    }
                    http_promise.success (data)=>
                        @list[chapter.id] = res =  @wrapResults data, chapter
                        def.resolve res
                    http_promise.error (err)=>
                        err_msg = [
                            "An error occured while getting results of chapter"
                            " #{chapter.id}:"
                        ]
                        def.reject err_msg
                        console.warn err_msg.join(''), err
                def.promise

            unsentenceIt: (str)=>
                # will remmove first capital letter of passed string if necessary
                if @STARTS_WITH_CAPITAL.test str  
                    str  = str.replace str[0], str[0].toLowerCase()
                str
        
            wrapResults: (results, chapter)=>
                results_obj =
                    share_sentence: results.share_sentence
                    chapter:  chapter
                    list: {}
                # wrap a set of results by calling @wrapResult on every result
                for scene_key, scene of results.scenes
                    results_obj.list[scene_key] = @wrapSceneResult(scene)
                results_obj

            wrapSceneResult: (sceneOptions)=>
                user_choice_idx = sceneOptions.you if sceneOptions.you?
                choice     = sceneOptions.options[user_choice_idx]
                if choice?
                    percentage = choice.percentage
                    title      = @unsentenceIt(choice.title)
                    resultWrapingObject =
                        userChoice: choice
                        percentage:
                            sentence: "Comme <b>#{percentage}%</b> des utilisateurs, #{title}"
                            raw: percentage
                            style: 
                                width: "#{percentage}%"
                    result = _.extend sceneOptions, resultWrapingObject
                else
                    result = sceneOptions
                result


])