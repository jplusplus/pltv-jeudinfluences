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
	if ($json_encode) {$body = json_encode($body);}
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
$app->get("/api/career", function() use ($app) {
	/**
	* Retrieve the career progression for the given token from the database.
	*
	*/
	$params = $app->request()->params();
	if (isset($params['token'])) {
		$career = R::findOne('career', 'token=?', array($params['token']));
	} else {
		if (isset($params['email'])) {
			$career  = R::findOne('career', 'email=?', array($params['email']));
		} else {
			return wrong(array('error' => 'token or email needed'));
		}
	}
	if (empty($career)) return wrong(array('error' => 'empty'));
	$export = $career->export();
	if (empty($export["scenes"])) return wrong(array('error' => 'undefined'));
	$scenes     = json_decode($career->scenes, true);
	$choices    = json_decode($career->choices, true);
	$last_scene = end($scenes);
	$response = array(
		"token"         => $career->token,
		"reached_scene" => $last_scene,
		"context"       => \app\helpers\Game::computeContext($export),
		"scenes"        => $scenes,
		"choices"       => $choices
	);
	return ok($response);
});

$app->post('/api/career', function() use ($app) {
	/**
	* Save the career progression in database
	* If token isn't given, create one and return it
	* expected body : {"reached_scene" : "2.2"}
	* or              {"scene" : "2.1", "choice": 2}
	*
	* TODO: delete
	*/
	$params = $app->request()->params();
	if (isset($params['token'])) {
		$token  = $params['token'];
		$career = R::findOne('career', 'token=?', array($token));
		if (empty($career)) return wrong(array('error' => 'empty'));
	} else {
		// generate a token and add it to the attribute
		$career          = R::dispense('career');
		$token           = str_replace(".", "", uniqid("", true));
		$career->token   = $token; # save the token
		$career->choices = "{}";
		$career->scenes  = "[]";
		$career->created = R::isoDateTime();
	}
	// update the career (json syntax)
	$data = json_decode($app->request()->getBody(), true);
	if (is_null($data)) return wrong(array("error" => "body invalid. Need json."));
	$scenes  = json_decode($career->scenes, true);
	$choices = json_decode($career->choices);
	// update field
	if (isset($data["reached_scene"])) {
		// TODO: check if already exists
		if (!in_array((string)$data["reached_scene"], $scenes)) {
			$scenes[] = (string)$data["reached_scene"];
			$career->scenes = json_encode($scenes);
		}
	}
	if (isset($data["scene"]) && isset($data["choice"])){
		$choices                 = json_decode($career->choices);
		$choices->$data["scene"] = $data["choice"];
		$career->choices         = json_encode($choices);
	}
	// save
	R::store($career);
	$response = array(
		"status"        => 'done',
		"token"         => $token,
		"reached_scene" => end($scenes),
		"context"       => \app\helpers\Game::computeContext($career->export()),
		"scenes"        => $scenes,
		"choices"       => $choices
	);
	return ok($response);
});

$app->post('/api/career/associate_email', function() use ($app) {
	/**
	* Associate an email to a token
	* expected body : `{"email" : "example@wanadoo.fr"}`
	*
	*/
	$params = $app->request()->params();
	if (!isset($params['token'])) {return wrong(array('error' => 'token needed'));}
	$token  = $params['token'];
	$career = R::findOne('career', 'token=?', array($token));
	if (empty($career)) {return wrong(array('error' => 'unknown token'));}
	$data = json_decode($app->request()->getBody(), false);
	if(isset($data->email) && filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
		$career->email = $data->email;
		R::store($career);
		// send email
		$app->view->appendData(array('token' => $token, 'host' => 'localhost:8080'));
		$message = $app->view->fetch('emails/saved_and_send_token.twig');
		$headers = "Content-Type: text/plain; charset=UTF-8";
		mail($data->email, $app->config("email_saving_subject"), $message, $headers);
		return ok(array('status' => 'done'));
	}
	return wrong(array('error' => 'email required'));
});

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

# -----------------------------------------------------------------------------
#
#    SUBSCRIBE TO THE NEWSLETTER
#
# -----------------------------------------------------------------------------
$app->post('/api/subscribe', function() use ($app) {
	// Angular send post data throught the body in JSON
	$body = json_decode( $app->request()->getBody() );
	$mc_apikey     = $app->config("mailchimp_apikey");
	$mc_id         = $app->config("mailchimp_id");
	$mc_datacenter = $app->config("mailchimp_datacenter");
	$mc_url        = "http://{$mc_datacenter}.api.mailchimp.com/1.3/?method=listSubscribe";
	$params = array(
		'email_address'=> $body->email,
		'apikey'=> $mc_apikey,
		'id' => $mc_id,
		'double_optin' => true,
		'update_existing' => false,
		'replace_interests' => true,
		'send_welcome' => false,
		'email_type' => 'html'
	);
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $mc_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, urlencode( json_encode($params) ));
	$result = curl_exec($ch);
	curl_close($ch);
	$data = json_decode($result);
	if ( is_object($data) && isset($data->error) ){
		wrong( array("error" => $data->error) );
	} else {
		ok( array("success" => "Look for the confirmation message.") );
	}
});

// EOF
