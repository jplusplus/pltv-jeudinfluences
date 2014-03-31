angular.module("spin.filter").filter "checkmark", ->
    (input)->if input then '\u2713' else '\u2718'
# EOF