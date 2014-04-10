angular.module("spin.animation").animation '.scene-entrance-animation', ["$timeout", "constant.settings", ($timeout, settings)->    
    removeClass: (element, className, done) ->    
        if className is "ng-hide"      
            element.stop().css("opacity", 0)
            element.animate opacity: 1, settings.sceneEntrance, done
        else
            done()
        return
    addClass: (element, className, done) ->    
        if className is "ng-hide"     
            element.stop().css("opacity", 1)
            element.animate opacity: 0, settings.sceneEntrance, done
        else
            done()
        return
]
# EOF