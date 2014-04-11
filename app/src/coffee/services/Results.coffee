angular.module("spin.service").factory("Results", [
    'User'
    'Plot'
    'constant.api' 
    '$rootScope'
    '$http'
    (User, Plot, api, $rootScope, $http)->
        new class Results

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
                    @list[chapter_id] = data
                http_promise.error (err)=>
                    err_msg = [
                        "An error occured while getting results of chapter"
                        " #{chapter_id}:"
                    ]
                    console.warn err_msg.join(''), err



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