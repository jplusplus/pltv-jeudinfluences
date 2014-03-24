angular.module('spin.controller',['ngResource'])
angular.module('spin.config',    ['ngResource'])
angular.module('spin.directive', ['ngResource'])
angular.module('spin.filter',    ['ngResource'])
angular.module('spin.service',   ['ngResource'])

app = angular.module('spin', ["ngRoute", "ngResource", "ngAnimate", "spin.filter", "spin.service", "spin.directive"])

# -----------------------------------------------------------------------------
#
#    CONFIGURATION
#       - set providers that configure services and specialized objects
# -----------------------------------------------------------------------------
app.config(['$interpolateProvider', '$routeProvider', ($interpolateProvider, $routeProvider) ->    

    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')

    $routeProvider.when("/",
        templateUrl: "partials/main.html"
        controller: "MainCtrl"
    ).otherwise redirectTo : "/"    
])


# EOF