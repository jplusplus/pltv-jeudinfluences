###
  Preload Images Directive
  Accepts a comma deliminated list of image paths which it loads immediately
  @source http://jsfiddle.net/rur_d/qU3Zs/1/
###
angular.module("spin.directive").directive "preload", ->    
    restrict: "E"
    scope:
        images: "&"
    link: (scope, elm, attrs) ->
        # Any
        checkQueue = -> scope.$broadcast "imagesPreloaded"  if queue is 0
          
        queue  = 0
        angular.forEach scope.images(), (imageSrc) ->                
            image = new Image()
            queue++
            image.onload = ->
                queue--
                do checkQueue
            image.src = imageSrc

        do checkQueue