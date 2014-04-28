<?php
namespace app\routes;

$app->get('/api/page/:slug', function($slug) use ($app) {
    
    // cache on production
    if( $app->getMode() != "development" ) {        
        $app->etag('api-plot');
        $app->expires('+10 minutes');
    }
    
    $page = \app\helpers\Page::getPage($slug);

    if($page) {
        return ok( array('page' => $page) );
    } else {        
        return ok( array('error' => 'Not found') );
    }
});

// EOF