angular.module("spin.animation").animation '.chapter-entrance-animation', ["$timeout", "constant.settings", ($timeout, settings)->    
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.css("opacity", 0)
            $timeout ->
                element.animate
                    opacity: 1
                , settings.chapterStarting/2, done
            # Wait 3000 seconds before the start of the animation
            , settings.chapterStarting/2
        else
            done()
        return
]
# EOF