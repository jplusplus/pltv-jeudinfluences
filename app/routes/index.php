<?php
namespace app\routes;

$app->get('/', function() use ($app) {
   
    // cache on production
    if( $app->getMode() != "development" ) {    
        $app->etag('home-index');
        $app->expires('+10 minutes');
        $app->response->headers->remove("Keep-Alive");
        $app->response->headers->set("Cache-Control", "max-age=600, s-maxage=600");    
    }

    // Template's locale variables
    $locales = array();

    // Add partner option
    $locales["partner"] = (int) $app->request()->params('partner');

    $app->render("index.twig", $locales );

})->name('Home');

// EOF
