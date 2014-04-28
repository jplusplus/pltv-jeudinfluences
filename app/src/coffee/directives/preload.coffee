###
  Preload Images Directive
  Accepts a comma deliminated list of image paths which it loads immediately
  @source http://jsfiddle.net/rur_d/qU3Zs/1/
###
angular.module("spin.directive").directive "preload", ['$timeout', ($timeout)->    
    restrict: "E"
    scope:
        images: "&"
        object: '='
    link: (scope, elm, attrs) ->
        # Any
        checkQueue = -> 
            if queue <= 0
                scope.$broadcast "imagesPreloaded"  
                scope.object[attrs.attr] = yes
                
        
        queue = 0
        scope.object[attrs.attr] = no
        angular.forEach scope.images(), (imageSrc) ->                
            image = new Image()
            queue++
            image.onerror = image.onload = ->
                queue--
                do checkQueue        
            image.src = imageSrc
        do checkQueue
]