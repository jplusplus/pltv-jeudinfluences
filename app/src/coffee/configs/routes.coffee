angular.module('spin.config').config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->    

    # Use HTML5 mode for routing
    $locationProvider.html5Mode yes

    $routeProvider.when("/",
        templateUrl: "partials/main.html"
        controller : "MainCtrl"
        resolve    : MainCtrl.resolve
    ).otherwise redirectTo : "/"    

]

