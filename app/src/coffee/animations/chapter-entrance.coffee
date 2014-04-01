angular.module("spin.animation").animation '.chapter-entrance-animation', ["$timeout", "constant.delay", ($timeout, delay)->    
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.css("opacity", 0)
            element.animate
                opacity: 1
            # Wait 3000 seconds before the end of the animation
            , delay.chapterStarting/2, -> $timeout(done, delay.chapterStarting/3)
        else
            done()
        return
]
# EOF