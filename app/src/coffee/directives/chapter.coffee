angular.module('spin.directive').directive "chapter", ->    
    restrict: "E"
    replace: false
    templateUrl: "partials/chapter.html"
    controller: 'ChapterCtrl'
    scope:
        src: "="