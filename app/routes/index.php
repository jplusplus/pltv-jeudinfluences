<?php
namespace app\routes;

$app->get('/', function() use ($app) {

    // $mode is "wait" or "index", depends of the current daate
    $mode = ($app->config("launching_date") && strtotime(date('Y-m-d H:i:s')) < strtotime($app->config("launching_date"))) ? "wait" : "index";    
   
    // cache on production
    if( $app->getMode() != "development" ) {    
        $app->etag('home-' . $mode);
        $app->expires('+10 minutes');
        $app->response->headers->remove("Keep-Alive");
        $app->response->headers->set("Cache-Control", "max-age=600, s-maxage=600");    
    }

    // Template's locale variables
    $locales = array();

    // Add partner option
    $locales["partner"] = (int) $app->request()->params('partner');

    if ($mode == "wait") {
        $template = "wait.twig";
    } else {
        $template = "index.twig";
    }

    $app->render($template, $locales );

})->name('Home');

// EOF
