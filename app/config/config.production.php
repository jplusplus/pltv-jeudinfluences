<?php

use RedBeanPHP\R;

function getenv_bool($name) {
	return in_array(strtolower(getenv($name)), ['true', 't', 1]);
}

if($env == 'production'){
	// Same as PDO constructor
	// @see https://www.php.net/manual/fr/pdo.construct.php
	$db_dsn = getenv('DATABASE_DSN') ?: 'mysql:host=127.0.0.1;dbname=pltv-jeudinfluences';
	$db_user = getenv('DATABASE_USER') ?: NULL;
	$db_pass = getenv('DATABASE_PASS') ?: NULL;
	$db_freeze = getenv_bool('DATABASE_FREEZE');

	R::setup($db_dsn, $db_user, $db_pass);
	// Freeze the database which means Redbean won't execute 
	// tables describes to modify their schema.
	if ($db_freeze) {
		R::freeze();
	}
}

$app->configureMode('production', function () use ($app) {
	$app->config(array(
		'log.enabled'          => getenv_bool('SLIM_LOG'),
		'debug'                => getenv_bool('SLIM_DEBUG'),
		'display_debug_toolbar'=> getenv_bool('SLIM_DEBUG_TOOLBAR'),
		'cache'                => getenv('SLIM_CACHE') ?: '../tmp/cache',
		'archimade_idsite'     => 2439,
		// assets
		'static_url'           => "/",
		// for video, sounds and large files
		'media_url'            => getenv('MEDIA_URL') ?: "http://d328jlweo9aqvq.cloudfront.net",
		'launching_date'       => "2014-05-06T10:00:00", # after this date, switch to the game home page
		// Mailchimp configuration
		'mailchimp_id'         => getenv('MAILCHIMP_ID') ?: '',
		'mailchimp_datacenter' => getenv('MAILCHIMP_DATACENTER') ?: '', # ex: us8
		'mailchimp_apikey'     => getenv('MAILCHIMP_APIKEY') ?: '',
		// Configure mandrill mailler here
		'mandrill_api_key' => getenv('MANDRILL_API_KEY') ?: '',
		'mandrill_from' => getenv('MANDRILL_FROM') ?: 'info@jeudinfluences.fr',
		// Opening dates of each chapter
		'opening_dates'        => array(
			'1'                => "2014-03-10T16:00:00",
			'2'                => "2014-03-10T16:00:00",
			'3'                => "2014-03-10T16:00:00",
			'4'                => "2014-03-10T16:00:00"
		),
		// Time after which we should re-aggregate summary (in hours)
		'summary_aggregation_expired' => 6
	));

});

// EOF
