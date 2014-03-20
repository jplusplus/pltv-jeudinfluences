<?php
namespace app\routes;

# -----------------------------------------------------------------------------
#
#    OUPUTS
#
# -----------------------------------------------------------------------------

function ok($body) {
	global $app;
	$response = $app->response();
	$response['Content-Type'] = 'application/json';
	$response->status(200);
	$response->body(json_encode($body));
}

function wrong($body, $status=500) {
	global $app;
	$response = $app->response();
	$response['Content-Type'] = 'application/json';
	$response->status($status);
	$response->body(json_encode($body));	
}

# -----------------------------------------------------------------------------
#
#    API
#
# -----------------------------------------------------------------------------
$app->get('/api/career(/:token)', function($token=NULL) use ($app) {
	/**
	* Retrieve the career progression for the given token from the database.
	* If no token are given, use the session to guess it.
	*
	* TODO:
	* [ ] (check if token is different than the one we have from session)
	* [ ] token should be generated when the user start the game, at the first save.
	*
	*/
	// NOTE : it's hard to get an email from a GET parameter. Screw you PHP.
	// (see https://github.com/codeguy/Slim/issues/359)
	// if(filter_var($token, FILTER_VALIDATE_EMAIL)) {echo "this is an email";}
	if (!isset($token)) {
		// $token = from session;
	}
	// retrieve career from database for the given token
	$career = NULL;
	ok($career);
});

$app->post('/api/career', function() use ($app) {
	/**
	* Save the career progression in database.
	*
	* TODO:
	* [ ] token should be generated when the user start the game, at the first save.
	*
	*/
	// $token = from session;
});

$app->get('/api/plot', function() use ($app) {
	/**
	* Retrieve the list of opened chapters and their scenes from the `chapters` folder.
	* Chapter must have a name like [0-9].json
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
	ok($response);
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
