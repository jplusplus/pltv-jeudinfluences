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
		'archimade_idsite'     => 2439,
		'secret_session_key'   => "ddf31d78-0508-4fc5-85e3-ef3da4f35e67",
		// assets
		'static_url'           => "/",
		'media_url'            => "/media/", # for video, sounds and large files
		// template file for the homepage
		'home_template'    => function () {
			$launching_date = "2014-05-06T10:00:00";
			if (strtotime(date('Y-m-d H:i:s')) >= strtotime($launching_date)) {
				return "index.twig";
			} else {
				return "wait.twig";
			}
		},
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
