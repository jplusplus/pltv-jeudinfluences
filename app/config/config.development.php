<?php

use RedBean_Facade as R;

if($env == 'development'){
	R::setup('sqlite:../tmp/db.sqlite', NULL, NULL);
}

$app->configureMode('development', function () use ($app) {
	$app->config(array(
		'log.enabled'          => true,
		'debug'                => true,
		'cache'                => false,
		'archimade_idsite'     => 2439,
		// assets
		'static_url'           => "/",
		// for video, sounds and large files
		'media_url'            => "http://localhost/J++/Projects/pltv-spin-media/",
		// after this date, switch to the game home page
		'launching_date'       => "2010-01-01T10:00:00", 
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
