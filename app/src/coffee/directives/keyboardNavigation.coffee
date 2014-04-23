angular.module('spin.directive').directive  'keyboardNavigation', [
    '$rootScope'
    'KeyboardCommands'
    ($rootScope, KeyboardCommands)->
        restrict: "A"
        link: (scope, elem, attrs)->
            angular.element('body').bind "keyup", (e)->
                cmd = KeyboardCommands.get e.which
                if typeof cmd is 'function'
                    $rootScope.safeApply ->
                        cmd(e)
                    do e.preventDefault
            # # scope.$watch KeyboardCommands.listCommands, onCommandsLoaded, yes
]