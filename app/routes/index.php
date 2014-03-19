<?php
namespace app\routes;

date_default_timezone_set('Europe/Paris');

function ok($response) {
	header("Content-Type: application/json");
	echo json_encode($response);
	exit;
}

# -----------------------------------------------------------------------------
#
#    PAGES
#
# -----------------------------------------------------------------------------

$app->get('/', function() use ($app) {
	$app->view()->appendData(array('viewName'=>'Home'));
	$app->render('index.twig');
})->name('Home');

# -----------------------------------------------------------------------------
#
#    API
#
# -----------------------------------------------------------------------------
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
		$opening_date   = $chapter["opening_date"];
		// compare the opening date with today : keep only opened chapters
		if(strtotime(date('Y-m-d H:i:s')) >= strtotime($opening_date))  {
			// retrieve scenes files for the current chapter
			$scenes  = glob('chapters/'.$chapter_number.'.?.json', GLOB_BRACE);
			$chapter['scenes'] = array();
			foreach ($scenes as $scene_filename) {
				$content             = file_get_contents($scene_filename);
				$scene               = json_decode($content, true);
				$chapter['scenes'][] = $scene;
			}
			$response[] = $chapter;
		}
	}
	ok($response);
});

// EOF
