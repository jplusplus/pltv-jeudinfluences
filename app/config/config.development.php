<?php

use RedBeanPHP\R;

if($env == 'development'){
	R::setup('sqlite:../db.sqlite', NULL, NULL);
}


$app->configureMode('development', function () use ($app) {
	$app->config(array(
		'log.enabled'          => true,
		'debug'                => true,
		'cache'                => false,	
		// assets
		'static_url'           => "/",
		// for video, sounds and large files
		'media_url'            => "http://d328jlweo9aqvq.cloudfront.net",
		// Configure mandrill mailler here
		'mandrill_api_key'     => '',
		'mandrill_from'        => 'info@jeudinfluences.fr',
		// Mail settings
		'email_saving_subject' => "Jeu d'influences : Votre partie est sauvegardée",
		// Opening dates of each chapter
		'opening_dates'        => array(
			'1'                => "2014-03-19T16:00:00",
			'4'                => "2014-03-19T16:00:00"
		),
		// Time after which we should re-aggregate summary (in hours)
		'summary_aggregation_expired' => 0.2
	));
});

// EOF
