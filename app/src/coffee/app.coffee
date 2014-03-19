angular.module('spin.config',     ['ngResource'])
angular.module('spin.directive',  ['ngResource'])
angular.module('spin.filter',     ['ngResource'])
angular.module('spin.service',    ['ngResource'])

app = angular.module('spin', ["ngRoute", "spin.filter", "spin.service"])

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