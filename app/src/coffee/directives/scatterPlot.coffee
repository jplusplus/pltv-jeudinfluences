angular.module('spin.directive').directive "scatterPlot", [
    'Plot'
    'User'
    (Plot, User)->
        replace: true
        restrict: "E"
        scope: 
            results: '='
            point: '@'
        transclude: true
        templateUrl: "partials/scatter-plot.html"
        link: (scope, elem, attrs)->
            axes =
                horizontal: 
                    key: 'guilt'
                    names: 
                        max: 'non coupable'
                        min: 'coupable'

                vertical:
                    key: 'honesty'
                    names: 
                        max: 'aveux'
                        min: 'mensonges'

            scope.axes = axes

            scope.allPoints = -> 
                scope.points or []

            scope.getDotStyle = (dot)-> 
                left: "#{dot.left}%"
                top: "#{dot.top}%"

            user_dot = ->
                user: true
                guilt: User.indicators.guilt
                honesty:   User.indicators.honesty

            get_min = (arr, el_key)->
                _.min(arr, (el)-> el[el_key])[el_key]

            get_max = (arr, el_key)->
                _.max(arr, (el)-> el[el_key])[el_key]


            fakeData = ->
                i = 0
                res = []

                # destroy me when its set.
                while i < 75
                    res.push
                        guilt: Math.floor(Math.random() * 100)
                        honesty:   Math.floor(Math.random() * 100)
                    i++
                res

            update  = (res)->
                processResults = (results)->
                    scales =
                        guilt:
                            max: get_max(results, 'guilt')

                        honesty: 
                            max: get_max(results, 'honesty')

                    create_dot = (result)->
                        h_axe = axes.horizontal.key
                        v_axe = axes.vertical.key
                        left_scale = scales[h_axe]
                        top_scale  = scales[v_axe]

                        left_val = 100 - (100 * result[h_axe] / left_scale.max )
                        top_val  = 100 - (100 * result[v_axe] / top_scale.max  )
                        # console.log 'left_val: ', left_val, ' - top_val: ', top_val
                        _.extend result, 
                            left: Math.floor left_val
                            top:  Math.floor top_val
                    
                    _.map results, create_dot

                if res.length < 1
                    res = fakeData()
                res.push user_dot()
                # do stuff & more
                scope.points = processResults(res) 

            scope.$watch -> 
                    scope.$eval 'results'
                , update


]