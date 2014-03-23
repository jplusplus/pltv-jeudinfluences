<?php

use RedBean_Facade as R;

if($env == 'production'){
	R::setup('mysql:host=127.0.0.1;dbname=AddYourDBNameHere','AddYourDBUser','AddYourDBPass');
}

$app->configureMode('production', function () use ($app) {
	$app->config(array(
		'log.enabled'          => true,
		'debug'                => false,
		'cache'                => realpath('../tmp/cache'),
		// assets
		'static_url'           => "/",
		'media_url'            => "/media/", # for video, sounds and large files
		// template file for the homepage
		// 'home_template' => "index.twig", // spin game
		'home_template'    => "wait.twig",  // launching page
		// Mailchimp configuration
		'mailchimp_id'         => '',
		'mailchimp_datacenter' => '', # ex: us8
		'mailchimp_apikey'     => '',
		// Opening dates of each chapter
		'opening_dates'        => array(
			// ex: '1'         => "2014-03-19T16:00:00",
		)
	));

	// TODO
	// * Emails

});

// EOF
