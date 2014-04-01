angular.module("spin.animation").animation '.chapter-entrance-animation', ["$timeout", ($timeout)->    
    # make sure to call the done() function when the animation is complete.
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.css("opacity", 0)
            element.animate
                opacity: 1
            # Wait 3000 seconds before the end of the animation
            , 3000, -> $timeout(done, 2000)
        else
            done()
        return
]
# EOF