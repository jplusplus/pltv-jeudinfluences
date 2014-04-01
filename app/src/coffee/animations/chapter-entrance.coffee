angular.module("spin.animation").animation '.chapter-entrance-animation', ["$timeout", "constant.delay", ($timeout, delay)->    
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.css("opacity", 0)
            $timeout ->
                element.animate
                    opacity: 1
                , delay.chapterStarting/2, done
            # Wait 3000 seconds before the start of the animation
            , delay.chapterStarting/2
        else
            done()
        return
]
# EOF