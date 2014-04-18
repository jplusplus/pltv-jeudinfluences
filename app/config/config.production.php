<?php

use RedBean_Facade as R;

if($env == 'production'){
	R::setup('mysql:host=127.0.0.1;dbname=AddYourDBNameHere','AddYourDBUser','AddYourDBPass');
}

$app->configureMode('production', function () use ($app) {
	$app->config(array(
		'log.enabled'          => true,
		'debug'                => false,
		'display_debug_toolbar'=> false,
		'cache'                => realpath('../tmp/cache'),
		'archimade_idsite'     => 2439,
		// assets
		'static_url'           => "/",
		// for video, sounds and large files
		'media_url'            => "http://d328jlweo9aqvq.cloudfront.net",
		'launching_date'       => "2014-05-06T10:00:00", # after this date, switch to the game home page
		// Mailchimp configuration
		'mailchimp_id'         => '',
		'mailchimp_datacenter' => '', # ex: us8
		'mailchimp_apikey'     => '',
		// Opening dates of each chapter
		'opening_dates'        => array(
			'1'                => "2014-03-10T16:00:00",
			'2'                => "2014-03-10T16:00:00",
			'3'                => "2014-03-10T16:00:00",
			'4'                => "2014-03-10T16:00:00"
		),
		// Time after which we should re-aggregate summary (in hours)
		'summary_aggregation_expired' => 6,
		// Configure mandrill mailler here
		'mandrill_api_key' => '',
		'mandrill_from' => ''
	));

});

// EOF
