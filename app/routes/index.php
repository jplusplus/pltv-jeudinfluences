<?php
namespace app\routes;

$app->get('/', function() use ($app) {
	$app->render($app->config("home_template"));
})->name('Home');

// EOF
