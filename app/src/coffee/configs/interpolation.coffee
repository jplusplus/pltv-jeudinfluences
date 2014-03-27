angular.module('spin.config').config ['$interpolateProvider', ($interpolateProvider) ->    
    $interpolateProvider.startSymbol('[[')
    $interpolateProvider.endSymbol(']]')
]