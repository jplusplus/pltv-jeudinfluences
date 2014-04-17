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
		return wrong(array('error' => 'token needed'));
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
		$career->finished = false;
		$career->culpabilite = 0;
		$career->honnetete = 0;
	}
	// update the career (json syntax)
	$data = json_decode($app->request()->getBody(), true);
	if (is_null($data)) return wrong(array("error" => "body invalid. Need json."));
	$scenes  = json_decode($career->scenes, true);
	$choices = json_decode($career->choices);

	// Recording choice...
	if (isset($data["scene"]) && isset($data["choice"])){
		$choices                 = json_decode($career->choices);
		$choices->$data["scene"] = $data["choice"];
		$career->choices         = json_encode($choices);
		// Get the scene to retreive available options
		$scene      = \app\helpers\Game::getScene($data["scene"]);
		$options    = \app\helpers\Game::getOptionsFromScene($scene);
		// Get the next_scene from the selected option.
		// We save it into data to save the scene reached
		$data["reached_scene"] = $options[$data["choice"]]["next_scene"];
	}

	// Recording progression...
	if (isset($data["reached_scene"])) {
		// TODO: check if already exists
		if (!in_array((string)$data["reached_scene"], $scenes)) {
			$scenes[] = (string)$data["reached_scene"];
			$career->scenes = json_encode($scenes);
		}
	}

	if (isset($data["is_game_done"]) && $data["is_game_done"]) {
		$context = \app\helpers\Game::computeContext($career);

		$career->finished = true;
		$career->culpabilite = $context['culpabilite'];
		$career->honnetete = $context['honnetete'];
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
		$app->view->appendData(array('token' => $token, 'host' => $_SERVER['HTTP_HOST']));
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

$app->get('/api/summary', function() use ($app) {
	/**
	* Chapter must have a name like [0-9].json
	*/
	$params = $app->request()->params();
	if (!isset($params['chapter'])) { return wrong(array('error' => 'chapter needed')); }
	$asked_chapter = $params['chapter'];

	// We retrieve the object in the database
	$summary_in_db = R::findOne('summary');

	// We retrieve the content of the .json files
	$summary = \app\helpers\Game::getSummary();

	// We check if the summary store in database is not too old
	$expired_limit = $app->config("summary_aggregation_expired") * 60 * 60;
	if (empty($summary_in_db) or time() - $summary_in_db['time'] > $expired_limit) {
		if (empty($summary_in_db)) {
			$summary_in_db = R::dispense('summary');
		}

		// We aggregate all responses
		$all_choices = array();
		foreach ($summary as $chapter => $choicesgroup) {
			$all_choices[$chapter] = array();
			foreach ($choicesgroup['scenes'] as $key => $value) {
				$all_choices[$chapter][$key] = array(0, 0);
			}
		}
		$all_careers = R::find('career');
		foreach ($all_careers as $career) {
			$_choices = json_decode($career['choices'], true);
			foreach ($all_choices as $chapter => $choicesgroup) {
				foreach ($choicesgroup as $choice => $choicearray) {
					if (isset($_choices[$choice])) {
						$all_choices[$chapter][$choice][$_choices[$choice]] += 1;
					}
				}
			}
		}

		// We compute the percentages
		foreach ($all_choices as &$choicegroup) {
			foreach($choicegroup as &$choice) {
				$total = $choice[0] + $choice[1];
				if ($total > 0) {
					$choice[0] = $choice[0] * 100 / $total;
					$choice[1] = $choice[1] * 100 / $total;
				}
			}
		}

		// We store the updated summary in database
		$summary_in_db['choices'] = json_encode($all_choices);
		$summary_in_db['time'] = time();
		R::store($summary_in_db);
	}

	if (isset($params['token'])) {
		$token_career = R::findOne('career', 'token=?', array($params['token']));
		$token_career['choices'] = json_decode($token_career['choices'], true);
	}

	// We inject the percentages in the returned object
	$returned_summary = $summary[$asked_chapter];
	$chapter_choices  = json_decode($summary_in_db['choices'], true);
	$chapter_choices  = $chapter_choices[$asked_chapter];
	foreach ($returned_summary['scenes'] as $choice_key => &$choice) {
		foreach ($choice['options'] as $key => &$option) {
			$option = array(
				"title" => $option,
				"percentage" => $chapter_choices[$choice_key][$key]
			);
		}
		if (isset($token_career) && isset($token_career['choices'][$choice_key])) {
			$choice['you'] = $token_career['choices'][$choice_key];
		}
	}

	// Finally, we set the results in the $summary object and send it back
	return ok($returned_summary);
});

$app->get('/api/summary/final', function() use ($app) {
	// $careers = R::find('career', 'finished=?', array(true));

	return ok(R::getAll("SELECT culpabilite, honnetete FROM career WHERE finished = 1;"));
});

$app->post('/api/erase', function() use ($app) {
	/**
	* Clear a career from a point in the plot.
	* Expect a token and a chapter or scene ID
	*/

	$params = $app->request()->params();
	$data = json_decode($app->request()->getBody(), false);
	// Check we have a token
	if (!isset($params['token'])) { return wrong(array('error' => 'token needed')); }
	// Check we know from where we should clean the career
	if (!isset($data->chapter) && !isset($data->since)) { return wrong(array()); }

	// Retrieve the career from the token
	$career = R::findOne('career', 'token=?', array($params['token']));
	if (empty($career)) { return wrong(array('error' => 'unknown token')); }

	// Retrieve from when we should erase the career
	$since = null;
	if (isset($data->since)) {
		if (preg_match('/^\d\.\d+$/', $data->since)) {
			$since = $data->since;
		} else { return wrong(array('error' => '\'since\' parameter malformed')); }
	} else if (isset($data->chapter)) {
		if (preg_match('/^\d$/', $data->chapter)) {
			$since = $data->chapter . ".1";
		} else { return wrong(array('error' => '\'chapter\' parameter malformed')); }
	}

	// Decode the JSON
	$career->scenes = json_decode($career->scenes, true);
	$career->choices = json_decode($career->choices, true);

	$chapter = intval(split('\.', $since)[0]);
	$scene = intval(split('\.', $since)[1]);

	// Clean the scenes array
	$career->scenes = array_filter($career->scenes, function($var) use ($chapter, $scene) {
		$_chapter = intval(split('\.', $var)[0]);
		$_scene = intval(split('\.', $var)[1]);
		if ($_chapter > $chapter) { return false; }
		else if ($_chapter == $chapter & $_scene >= $scene) { return false; }
		return true;
	});
	$career->scenes = array_values($career->scenes);

	// Clean the choices object
	$kept_choices = array_filter(array_keys($career->choices), function($var) use ($chapter, $scene) {
		$_chapter = intval(split('\.', $var)[0]);
		$_scene = intval(split('\.', $var)[1]);
		if ($_chapter > $chapter) { return false; }
		else if ($_chapter == $chapter & $_scene >= $scene) { return false; }
		return true;
	});
	$kept_choices = array_fill_keys($kept_choices, '');
	$career->choices = array_intersect_key($career->choices, $kept_choices);

	// Encode the JSON
	$career->scenes = json_encode($career->scenes);
	$career->choices = json_encode($career->choices);

	// Save in database
	R::store($career);

	return ok(array('status' => 'done'));
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
