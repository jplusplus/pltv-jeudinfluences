<?php
namespace app\routes;

$app->get('/', function() use ($app) {
	// $app->view()->appendData(array('viewName'=>'Home'));
	error_log($app->config("home_template"));
	$app->render($app->config("home_template"));
})->name('Home');

// EOF
