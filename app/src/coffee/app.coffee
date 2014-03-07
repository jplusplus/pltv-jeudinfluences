
app = angular.module('app', ["ngRoute", "spinFilters"])

# -----------------------------------------------------------------------------
#
#    CONFIGURATION
#		- set providers that configure services and specialized objects
# -----------------------------------------------------------------------------
app.config(['$interpolateProvider', ($interpolateProvider) ->
	$interpolateProvider.startSymbol('[[')
	$interpolateProvider.endSymbol(']]')
])

app.config(['$routeProvider', ($routeProvider) ->
	$routeProvider.when("/coucou",
		templateUrl : "partials/salutations.html"
		controller: "PouetCtrl"
	).otherwise(
		redirectTo : "/"
	)
])

# EOF
