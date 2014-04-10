angular.module("spin.animation").animation '.chapter-entrance-animation', ["$timeout", "constant.settings", ($timeout, settings)->    
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.stop().css("opacity", 0)
            $timeout ->
                element.animate
                    opacity: 1
                , settings.chapterEntrance/2, done
            # Wait 3000 seconds before the start of the animation
            , settings.chapterEntrance/2
        else
            done()
        return
    addClass: (element, className, done) ->    
        if className is "ng-hide"     
            element.stop().css("opacity", 1)
            element.animate opacity: 0, settings.chapterEntrance/3, done
        else
            done()
        return
]
# EOF