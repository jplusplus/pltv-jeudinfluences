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
	$export = $career->export();
	if (empty($career))         return wrong(array('error' => 'empty'));
	if (empty($export["json"])) return wrong(array('error' => 'undefined'));
	$response = array(
		"token"   => $career->token,
		"history" => json_decode($career->json, true)
	);
	return ok($response);
});

$app->post('/api/career', function() use ($app) {
	/**
	* Save the career progression in database
	* expected body : career's history in json as a list (see `doc/career.md`)
	* If token isn't given, create one and return it
	* TODO: partial update
	* TODO: delete
	* TODO: create empty
	*/
	$params = $app->request()->params();
	if (isset($params['token'])) {
		$token  = $params['token'];
		$career = R::findOne('career', 'token=?', array($token));
		if (empty($career)) {
			return wrong(array('error' => 'empty'));
		}
	} else {
		// generate a token and add it to the attribute
		$career          = R::dispense('career');
		$token           = str_replace(".", "", uniqid("", true));
		$career->token   = $token; # save the token
		$career->created = R::isoDateTime();
	}
	// update the career (json syntax)
	$career->json = $app->request()->getBody();
	R::store($career);
	return ok(array('status' => 'done', 'token' => $token));
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
	$response = array();
	$chapters = glob('chapters/[0-9*].json', GLOB_BRACE);
	foreach ($chapters as $chapter_filename) {
		$chapter_number = basename($chapter_filename, ".json");
		$content        = file_get_contents($chapter_filename);
		$chapter        = json_decode($content, true);
		$opening_dates  = $app->config("opening_dates");
		$opening_date   = isset($opening_dates[$chapter_number]) ? $opening_dates[$chapter_number] : null;
		// if there is an opening date, compare it with today : keep only opened chapters
		if(empty($opening_date) || strtotime(date('Y-m-d H:i:s')) >= strtotime($opening_date))  {
			// retrieve scenes files for the current chapter
			$scenes  = glob('chapters/'.$chapter_number.'.?*.json', GLOB_BRACE);
			$chapter['id']           = $chapter_number; # add the id from filename
			$chapter['opening_date'] = $opening_date; # add the opening_date from config into the chapter object
			$chapter['scenes']       = array();
			foreach ($scenes as $scene_filename) {
				$content             = file_get_contents($scene_filename);
				$scene               = json_decode($content, true);
				$scene["id"]         = join(".", array_slice(explode(".", basename($scene_filename, ".json")), 1)); # add the id from filename
				$chapter['scenes'][] = $scene;
			}
			$response[] = $chapter;
		}
	}
	return ok($response);
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
