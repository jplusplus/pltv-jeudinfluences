<?php

use RedBean_Facade as R;

if($env == 'development'){
	R::setup('sqlite:../tmp/db.sqlite','user','password');
}

$app->configureMode('development', function () use ($app) {
	$app->config(array(
		'log.enabled' => true,
		'debug' => true,
		'cache' => false,

		'home_template' => "wait.twig",
		// 'home_template' => "index.twig",

		# -----------------------------------
		#    OPENING DATES
		# -----------------------------------
		'opening_dates' => array(
			'1' => "2014-03-19T16:00:00",
			'4' => "2014-03-19T16:00:00"
		)
	));
});

// EOF
