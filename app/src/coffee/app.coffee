app = angular.module('spin', ["ngRoute", "spin.filters", "spin.services"])

# -----------------------------------------------------------------------------
#
#    CONFIGURATION
#       - set providers that configure services and specialized objects
# -----------------------------------------------------------------------------
app.config(['$interpolateProvider', ($interpolateProvider) ->
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
])

app.config(['$routeProvider', ($routeProvider) ->   
    $routeProvider.when("/",
        templateUrl: "partials/main.html"
        controller: "MainCtrl"
    ).otherwise redirectTo : "/"    
])

# EOF