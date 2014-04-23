angular.module("spin.service").factory "TimeoutStates", [
    ()->
        new class TimeoutStates
            constructor: ->
                @feedback = undefined
]