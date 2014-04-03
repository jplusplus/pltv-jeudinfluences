angular.module('spin.config').run ['$rootScope', ($rootScope)->  
    $rootScope.safeApply = (fn)->
        phase = @$root.$$phase
        if phase is "$apply" or phase is "$digest"
            do fn if fn and (typeof (fn) is "function")
        else
            @$apply fn
]