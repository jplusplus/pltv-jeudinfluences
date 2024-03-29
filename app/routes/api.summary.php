<?php
namespace app\routes;
use RedBeanPHP\R;

# -----------------------------------------------------------------------------
#
#    SUMMARY API
#
# -----------------------------------------------------------------------------

$app->get('/api/summary', function() use ($app) {

    // cache on production
    if( $app->getMode() != "development" ) {
        $app->etag('api-summary-final');
        $app->expires('+10 seconds');
    }

    /**
    * Chapter must have a name like [0-9].json
    */
    $params = $app->request()->params();
    if (!isset($params['chapter'])) { return wrong(array('error' => 'chapter needed')); }
    $asked_chapter = $params['chapter'];

    // We retrieve the object in the database
    $summary_in_db =  \app\helpers\Game::findSummary();    

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

        R::transaction(function() use (&$all_choices) {
            $security = 0;
            $get_by = 100;
            $offset = 0;
            while ($security < 15) {
                $all_careers = R::find('career', "ORDER BY id DESC LIMIT " . $get_by . " OFFSET " . $offset);
                if (!isset($all_careers)) { break; }

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

                if (count($all_careers) < $get_by) {
                    break;
                }

                $offset += $get_by;
                $security += 1;
            }
        });

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
        $token_career = \app\helpers\Game::findCareer($params['token']);
        if (isset($token_career)) {
            $token_career['choices'] = json_decode($token_career['choices'], true);
        }
    }

    // We inject the percentages in the returned object
    $returned_summary = $summary[$asked_chapter];
    $chapter_choices  = json_decode($summary_in_db['choices'], true);
    $chapter_choices  = $chapter_choices[$asked_chapter];              
    foreach ($returned_summary['scenes'] as $choice_key => &$choice) {
        foreach ($choice['options'] as $key => &$option) {  
            if( isset($chapter_choices[$choice_key]) ) {                
                $option = array(
                    "title" => $option,
                    "percentage" => $chapter_choices[$choice_key][$key]
                );
            }
        }
        if (isset($token_career) && isset($token_career['choices'][$choice_key])) {
            $choice['you'] = $token_career['choices'][$choice_key];
        }
    }

    // Finally, we set the results in the $summary object and send it back
    return ok($returned_summary);
});

$app->get('/api/summary/final', function() use ($app) {

    // cache on production
    if( $app->getMode() != "development" ) {
        $app->etag('api-summary-final');
        $app->expires('+30 seconds');
    }

    $tokencondition = "";
    $values = array();
    $params = $app->request()->params();
    if (isset($params['token'])) {
        $tokencondition = " AND token <> :token";
        $values = array(":token" => $params['token']);
    }

    $result = array();

    R::transaction(function() use (&$result, $tokencondition, $values) {
        $security = 0;
        $get_by = 100;
        $offset = 0;
        while ($security < 5) {
            $request  = "SELECT id, guilt, honesty FROM career";
            $request .= " WHERE finished = 1";
            $request .= $tokencondition;
            $request .= " ORDER BY id DESC";
            $request .= " LIMIT " . strval($get_by) . " OFFSET " . strval($offset);
            $partial_result = R::getAll($request, $values);

            $result = array_merge($result, $partial_result);

            if (count($partial_result) < $get_by) {
                break;
            }

            $offset += $get_by;
            $security += 1;
        }
    });

    return ok($result, true, true);
});

// EOF