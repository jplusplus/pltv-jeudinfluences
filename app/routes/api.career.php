<?php
namespace app\routes;
use Mailgun\Mailgun;
use RedBeanPHP\R;

# -----------------------------------------------------------------------------
#
#    CAREER API
#
# -----------------------------------------------------------------------------
$app->get("/api/career", function() use ($app) {
    /**
    * Retrieve the career progression for the given token from the database.
    */

    // cache on production
    if( $app->getMode() != "development" ) {       
        $app->etag('api-career');
        $app->expires('+30 seconds');    
    }
    
    $params = $app->request()->params();
    if (isset($params['token'])) {
        $career = \app\helpers\Game::findCareer($params['token']);
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
        $career = \app\helpers\Game::findCareer($token);
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
        $career->guilt = 0;
        $career->honesty = 0;
    }
    // update the career (json syntax)
    $data = json_decode($app->request()->getBody(), true);
    if (is_null($data)) return wrong(array("error" => "body invalid. Need json."));
    $scenes  = json_decode($career->scenes, true);
    $choices = json_decode($career->choices);

    
    // Recording choice...
    if (isset($data["scene"]) && isset($data["choice"])){
        $choices                 = json_decode($career->choices);
        $choices->{$data["scene"]} = $data["choice"];
        $career->choices         = json_encode($choices);
        // NOTE : commented to prevent a heavy and unecessary operation
        // // Get the scene to retreive available options
        // $scene      = \app\helpers\Game::getScene($data["scene"]);
        // $options    = \app\helpers\Game::getOptionsFromScene($scene);
        // // Get the next_scene from the selected option.
        // // We save it into data to save the scene reached
        // $data["reached_scene"] = $options[$data["choice"]]["next_scene"];
    }

    // Recording progression...
    if (isset($data["reached_scene"])) {
        // TODO: check if already exists
        if (!in_array((string)$data["reached_scene"], $scenes, true)) {
            $scenes[] = (string)$data["reached_scene"];
            $career->scenes = json_encode($scenes);
        }
    }

    if (isset($data["is_game_done"]) && $data["is_game_done"]) {
        $context = \app\helpers\Game::computeContext($career);

        $career->finished = true;
        $career->guilt = $context['guilt'];
        $career->honesty = $context['honesty'];
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
    $career = \app\helpers\Game::findCareer($token);
    if (empty($career)) {return wrong(array('error' => 'unknown token'));}
    $data = json_decode($app->request()->getBody(), false);
    if(isset($data->email) && filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
        $career->email = $data->email;
        R::store($career);

        $app->view->appendData(array('token' => $token, 'host' => $_SERVER['HTTP_HOST']));

        $mailgun_key = $app->config("mailgun_api_key");
        $mailgun_domain = $app->config("mailgun_domain");
        $mailgun_client = Mailgun::create($mailgun_key);

        $result = $mailgun_client->messages()->send($mailgun_domain, [
            'subject' => $app->config("email_saving_subject"),
            'from'    => $app->config("mailgun_from"),
            'to'      => $data->email,
            'html'    => $app->view->fetch("emails/saved_and_send_token.twig")
        ]);

        return ok(array('status' => 'done', 'result' => $result));
    }
    return wrong(array('error' => 'email required'));
});

$app->post('/api/career/erase', function() use ($app) {
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
    $career = \app\helpers\Game::findCareer($params['token']);
    if (empty($career)) { return wrong(array('error' => 'unknown token')); }

    // Decode the JSON
    $career->scenes = json_decode($career->scenes, true);
    $career->choices = json_decode($career->choices, true);

    // Retrieve from when we should erase the career
    $since = null;
    if (isset($data->since)) {
        if (preg_match('/^\d\..+$/', $data->since)) {
            $since = $data->since;
        } else { return wrong(array('error' => '\'since\' parameter malformed')); }
    } else if (isset($data->chapter)) {
        if (preg_match('/^\d$/', $data->chapter)) {
            foreach ($career->scenes as $scene) {
                if (preg_match('/^'.$data->chapter.'\./', $scene)) {
                    $since = $scene;
                    break;
                }
            }
            if (!isset($since)) { return wrong(array('error' => 'Chapter '.$data->chapter.' not found')); }

        } else { return wrong(array('error' => '\'chapter\' parameter malformed')); }
    }

    if (array_search($since, $career->scenes, true) === false) { return wrong(array('error' => 'Scene '.$data->since.' not found')); }

    // Clean the scenes array
    array_splice($career->scenes, array_search($since, $career->scenes, true) + 1);
    $career->scenes = array_values($career->scenes);

    // Clean the choices object
    $kept_choices = array_values($career->scenes);
    array_splice($kept_choices, sizeof($kept_choices) - 1);
    $kept_choices = array_fill_keys($kept_choices, '');
    $career->choices = array_intersect_key($career->choices, $kept_choices);

    $copied_scenes = $career->scenes;
    $copied_choices = $career->choices;

    // Encode the JSON
    $career->scenes = json_encode($career->scenes);
    $career->choices = json_encode((object)$career->choices);

    // Save in database
    R::store($career);

    $response = array(
        "token"         => $career->token,
        "reached_scene" => end($copied_scenes),
        "context"       => \app\helpers\Game::computeContext($career->export()),
        "scenes"        => $copied_scenes,
        "choices"       => $copied_choices
    );

    return ok($response);
});

// EOF