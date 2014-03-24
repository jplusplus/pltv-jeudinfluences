<?php

use RedBean_Facade as R;

if($env == 'development'){
	R::setup('sqlite:../tmp/db.sqlite','user','password');
}

$app->configureMode('development', function () use ($app) {
	$app->config(array(
		'log.enabled'          => true,
		'debug'                => true,
		'cache'                => false,
		// assets
		'static_url'           => "/",
		'media_url'            => "/media/", # for video, sounds and large files
		// Choose the right template for the homepage
		//'home_template' => "index.twig", // spin game
		'home_template' => "wait.twig", // launching page
		// Mailchimp configuration
		'mailchimp_id'         => '',
		'mailchimp_datacenter' => '', # ex: us8
		'mailchimp_apikey'     => '',
		// Opening dates of each chapter
		'opening_dates'        => array(
			'1'                => "2014-03-19T16:00:00",
			'4'                => "2014-03-19T16:00:00"
		)
	));
});

// EOF
