angular.module("spin.service").factory("Results", [
    'User'
    'Plot'
    'constant.api' 
    '$rootScope'
    '$http'
    (User, Plot, api, $rootScope, $http)->
        new class Results
            STARTS_WITH_CAPITAL: /^[A-Z]/
            constructor: ->
                @list = @list or {}
                $rootScope.$watch =>
                        @chapters().length
                    , @onChaptersLoaded

            chapters: => if Plot.chapters? then Plot.chapters else []

            get: (chapter_id)=> @list[chapter_id]

            resultsForChapter: (chapter_id)=>
                return @list[chapter_id] if @list[chapter_id]
                url  = api.results
                conf =
                    params:
                        chapter: chapter_id
                        token: User.token

                http_promise = $http.get(url, conf)
                http_promise.success (data)=>
                    @list[chapter_id] = @wrapResults data
                http_promise.error (err)=>
                    err_msg = [
                        "An error occured while getting results of chapter"
                        " #{chapter_id}:"
                    ]
                    console.warn err_msg.join(''), err

            unsentenceIt: (str)=>
                # will remmove first capital letter of passed string if necessary
                if @STARTS_WITH_CAPITAL.test str  
                    str  = str.replace str[0], str[0].toLowerCase()
                str
        
            wrapResults: (results)=>
                # wrap a set of results by calling @wrapResult on every result
                for res_key, result of results
                    results[res_key] = @wrapResult(result)
                results

            wrapResult: (result)=>
                user_choice_idx = result.you if result.you?
                choice     = result.options[user_choice_idx]
                if choice?
                    percentage = choice.percentage
                    title      = @unsentenceIt(choice.title)
                    resultWrapingObject = 
                        percentage:
                            sentence: "Comme <b>#{percentage}%</b> des utilisateurs, #{title}"
                            raw: percentage
                            style: 
                                width: "#{percentage}%"
                    result = _.extend result, resultWrapingObject
                result

            onChaptersLoaded: (chapter_count)=>
                return unless chapter_count and chapter_count > 0
                # if chapters are available we will load results for every 
                # saw chapter
                last_chapter     = Plot.chapter(User.chapter)
                last_chapter_idx = Plot.chapters.indexOf last_chapter
                index = 0
                while index < last_chapter_idx + 1
                    chapter = Plot.chapters[index]
                    @resultsForChapter chapter.id 
                    index++

])