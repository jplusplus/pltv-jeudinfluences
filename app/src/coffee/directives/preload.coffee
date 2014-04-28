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
            if queue is 0
                $timeout ->
                    scope.$broadcast "imagesPreloaded"  
                    scope.object[attrs.attr] = yes
                , 5000
        
        # Only queue for 50% of the images
        queue = -1 * scope.images().length * 0.5
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