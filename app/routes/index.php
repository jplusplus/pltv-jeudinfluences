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
    # Template's locale variables
    $locales = array();

    $archimade = realpath("../vendor/archimade/kit_archimade.php");
    // As Archimade is a private submodule, we made not mandatory
    if( file_exists($archimade) and is_integer($app->config("archimade_idsite")) ) {        
        require_once $archimade;
        $token = $mode == "wait" ? 'page-attente' : 'home';
        $arche = \ArcheHtml::getArche( $app->config("archimade_idsite"), $token);
        
        $locales["archimade"] = array(
            "variables"  => $arche->getTagsScript('variable'),
            "tags"       => array_merge( 
                $arche->getTagsCss(), 
                $arche->getTagsLinks(), 
                $arche->getTagsScript('header')
            ),
            "header" => $arche->getBodyHeader(),
            "footer" => $arche->getFullFooter()
        );

    }
    if ($mode == "wait") {
        $template = "wait.twig";
    } else {
        $template = "index.twig";
    }
    $app->render($template, $locales );

})->name('Home');

// EOF
