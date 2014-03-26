<?php

namespace app;
use RedBean_Facade as R;
date_default_timezone_set('Europe/Paris');

chdir ('../app/');

//Register lib autoloader
require '../composer_modules/autoload.php';

// Prepare app
require 'config/config.env.php';

$app = new \Slim\Slim(array(
	'mode' => $env,
	'view' => new \Slim\Views\Twig(),
	'templates.path' => '../app/views'
));

//Loads all needed subfiles
require 'bootstrap.php';

// Prepare view
$app->view->parserOptions = array(
	'debug' => true,
	'cache' => $app->config('cache'),
);

$app->view->parserExtensions = array(
	new \Slim\Views\TwigExtension(),
	new \app\SpinTwigExtension()
);

//Load 404 Route
$app->notFound(function () use ($app) {	
	$app->redirect('/404.html');
});

$app->view->setData(
	array(
		'MODE'             => $app->getMode(),
		'ARCHIMADE_IDSITE' => $app->config("archimade_idsite"),
		'MEDIA_URL'        => $app->config("media_url"),
		'STATIC_URL'       => $app->config("static_url")
	)
);

//Run
$app->run();
R::close();

// EOF
