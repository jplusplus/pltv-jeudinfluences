angular.module('spin.directive').directive "debugToolbar", [
    'Plot'
    'User'
    (Plot, User)->    
        restrict: "E"
        replace: true
        templateUrl: "partials/debug-toolbar.html"
        scope: false
        controller: ['$scope', ($scope)->
            $scope.setChapter = (val)->
                console.log 'setChapter called'
                $scope.safeApply ->
                    User.chapter = val


            $scope.setScene = (val)->
                $scope.safeApply ->
                    User.scene = val


            $scope.setSequence = (val)->
                $scope.safeApply ->
                    User.sequence = val

            $scope.restartCurrentChapter = ->
                console.log 'restartCurrentChapter called'
                $scope.safeApply ->
                    User.lastChapterChanging = Date.now()
                    User.scene   = 1
                    User.sequence = 0

            $scope.restartGame = ->
                $scope.safeApply ->
                    User.newUser()
                    User.inGame = no
                    User.chapter = 1
                    User.scene = 1
                    User.sequence = 0

        ]
        link: (scope, elem, attrs)->
            scope.$watch ->
                    User.chapter
                , (val)->
                    scope.currentChapter  = val

            scope.$watch ->
                    User.scene
                , (val)->
                    scope.currentScene    = val

            scope.$watch ->
                    User.sequence
                , (val)->
                    scope.currentSequence = val

            scope.hidden = yes

]