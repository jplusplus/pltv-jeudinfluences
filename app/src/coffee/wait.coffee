app = angular.module('spin', ["ngAnimate"])

class WaitCtrl
    @$inject: ["$scope", "$http"]
    constructor: (@scope, @http)->
        @scope.submit = @submit
    # Submit the form to register the user
    submit: =>
        @http.post("/api/subscribe", email: @scope.email)
            .success( => @scope.success = yes )
            .error( => @scope.error = yes )
