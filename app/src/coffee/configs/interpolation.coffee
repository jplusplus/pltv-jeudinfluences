angular.module('spin.config').config ['$interpolateProvider', '$httpProvider', ($interpolateProvider, $httpProvider) ->    
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]
