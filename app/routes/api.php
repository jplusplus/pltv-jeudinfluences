<?php
namespace app\routes;
use RedBean_Facade as R;

# -----------------------------------------------------------------------------
#
#    OUPUTS
#
# -----------------------------------------------------------------------------
function ok($body, $json_encode=true) {
	global $app;
	$response = $app->response();
	$response['Content-Type'] = 'application/json';
	$response->status(200);
	if ($json_encode) {$body = json_encode($body, JSON_NUMERIC_CHECK);}
	$response->body($body);
}

function wrong($body, $status=500,  $json_encode=true) {
	global $app;
	$response = $app->response();
	$response['Content-Type'] = 'application/json';
	$response->status($status);
	if ($json_encode) {$body = json_encode($body);}
	$response->body($body);
}

# -----------------------------------------------------------------------------
#
#    API
#
# -----------------------------------------------------------------------------
$app->get('/api/plot', function() use ($app) {
	/**
	* Retrieve the list of opened chapters and their scenes from the `chapters` folder.
	* Chapter must have a name like [0-9].json
	* TODO: to be cached
	*/
	
	// cache on production
	if( $app->getMode() != "development" ) {		
		$app->etag('api-plot');
		$app->expires('+10 minutes');
	}
    
	$plot = \app\helpers\Game::getPlot($app->config("opening_dates"));
	return ok($plot);
});

// EOF
