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
                User.chapter = val


            $scope.setScene = (val)->
                User.scene = val


            $scope.setSequence = (val)->
                User.sequence = val

            $scope.restartCurrentChapter = ->
                User.scene    = 1
                User.sequence = 0
                User.saveChapterChanging()

            $scope.restartGame = -> User.newUser()

            $scope.gameOver = -> 
                User.isGameOver = !User.isGameOver

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