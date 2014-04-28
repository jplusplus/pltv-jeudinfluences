angular.module('spin.directive').directive "debugToolbar", [
    'Plot'
    'User'
    (Plot, User)->    
        restrict: "E"
        replace: true
        templateUrl: "partials/debug-toolbar.html"
        scope: false
        controller: ['$scope', 'User', ($scope, User)->            
            # Update user progression
            $scope.update = ->
                # Collect input values
                values = [$scope.inputChapter, $scope.inputScene, $scope.inputSequence]
                # Update user object
                [User.chapter, User.scene, User.sequence] = values
                do User.eraseCareerSinceNow
                do User.updateCareer
            # Action on the game state
            $scope.gameOver = -> User.isGameOver = !User.isGameOver
            $scope.gameDone = -> 
                User.isGameDone = !User.isGameDone
                User.inGame     = !User.isGameDone
            $scope.restartGame           = -> User.newUser()
            $scope.restartCurrentChapter = -> User.restartChapter()

        ]
        link: (scope, elem, attrs)->
            scope.$watch (->User.chapter),  (val)-> scope.inputChapter = val
            scope.$watch (->User.scene),    (val)-> scope.inputScene = val
            scope.$watch (->User.sequence), (val)-> scope.inputSequence = val

            scope.hidden = yes

]