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
		'archimade_idsite'     => null,
		'secret_session_key'   => "ddf31d78-0508-4fc5-85e3-ef3da4f35e67",
		// assets
		'static_url'           => "/",
		'media_url'            => "/media/", # for video, sounds and large files
		// 'launching_date'       => "2013-01-01T10:00:00", # after this date, switch to the game home page
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
