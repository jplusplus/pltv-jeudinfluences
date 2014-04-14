angular.module("spin.animation").animation '.scene-entrance-animation', ["constant.settings", (settings)->    

    enter: (element, done) ->       
        element.css("opacity", 0)
        jQuery(element[0]).animate opacity: 1, settings.sceneEntrance, done
        # Catch canceling
        (isCanceled)-> (jQuery(element[0]).stop() if isCanceled)

    leave: (element, done) ->     
        element.css("opacity", 1)
        jQuery(element[0]).animate opacity: 0, settings.sceneEntrance, done
        # Catch canceling
        (isCanceled)-> (jQuery(element[0]).stop() if isCanceled)
]
# EOF