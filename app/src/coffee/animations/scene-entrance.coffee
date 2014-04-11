angular.module("spin.animation").animation '.scene-entrance-animation', ["$timeout", "constant.settings", ($timeout, settings)->    

    enter: (element, done) ->   
        element.css("opacity", 0)
        element.animate opacity: 1, settings.sceneEntrance, done
        # Catch canceling
        (isCanceled)-> (jQuery(element).stop() if isCanceled)

    leave: (element, done) ->     
        element.css("opacity", 1)
        element.animate opacity: 0, settings.sceneEntrance, done
        # Catch canceling
        (isCanceled)-> (jQuery(element).stop() if isCanceled)
]
# EOF