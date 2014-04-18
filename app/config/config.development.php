<?php

use RedBean_Facade as R;

if($env == 'development'){
	R::setup('sqlite:../db.sqlite', NULL, NULL);
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
		'media_url'            => "http://jacob.jplusplus.org/~pirhoo/pltv-spin",
		// after this date, switch to the game home page
		'launching_date'       => "2010-01-01T10:00:00", 
		// Mailchimp configuration
		'mailchimp_id'         => '',
		'mailchimp_datacenter' => '', # ex: us8
		'mailchimp_apikey'     => '',
		// Mail settings
		'email_saving_subject' => "Jeu d'influences : Votre partie est sauveardée",
		// Opening dates of each chapter
		'opening_dates'        => array(
			'1'                => "2014-03-19T16:00:00",
			'4'                => "2014-03-19T16:00:00"
		),
		// Time after which we should re-aggregate summary (in hours)
		'summary_aggregation_expired' => 0.2,
		'mandrill_api_key'     => '',
		'mandrill_from'        => 'info@jeudinfluences.fr'
	));
});

// EOF
