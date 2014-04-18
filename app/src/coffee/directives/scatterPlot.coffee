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
                horizontal: 'culpabilite'
                vertical:   'honnetete'

            scope.allPoints = -> 
                scope.points or []

            scope.getDotStyle = (dot)-> 
                left: "#{dot.left}%"
                top: "#{dot.top}%"

            user_dot = ->
                user: true
                culpabilite: User.indicators.culpabilite
                honnetete:   User.indicators.honnetete

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
                        culpabilite: Math.floor(Math.random() * 100)
                        honnetete:   Math.floor(Math.random() * 100)
                    i++
                console.log res
                res

            update  = (res)->
                processResults = (results)->
                    scales = 
                        culpabilite:
                            # min: get_min(results, 'culpabilite')
                            max: get_max(results, 'culpabilite')

                        honnetete: 
                            # min: get_min(results, 'honnetete')
                            max: get_max(results, 'honnetete')

                    console.log "scales = ", scales

                    create_dot = (result)->
                        h_axe = axes.horizontal
                        v_axe = axes.vertical
                        left_scale = scales[h_axe]
                        top_scale  = scales[v_axe]

                        left_val = 100 * result[h_axe] / left_scale.max
                        top_val  = 100 * result[v_axe] / top_scale.max
                        # console.log 'left_val: ', left_val, ' - top_val: ', top_val
                        _.extend result, 
                            left: Math.floor left_val
                            top:  Math.floor top_val
                    
                    _.map results, create_dot

                if res.length < 10
                    res = fakeData()
                res.push user_dot()
                # do stuff & more
                scope.points = processResults(res) 

            scope.$watch -> 
                    scope.$eval 'results'
                , update


]