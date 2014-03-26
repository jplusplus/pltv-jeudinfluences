<?php
namespace app\routes;

$app->get('/', function() use ($app) {

    # Template's locale variables
    $locales = array();

    $archimade = realpath("../vendor/archimade/kit_archimade.php");
    // As Archimade is a private submodule, we made not mandatory
    if( file_exists($archimade) and is_integer($app->config("archimade_idsite")) ) {        
        require_once $archimade;
        $arche = \ArcheHtml::getArche( $app->config("archimade_idsite"), 'default');
        
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
    if ($app->config("launching_date") && strtotime(date('Y-m-d H:i:s')) < strtotime($app->config("launching_date"))) {
        $template = "wait.twig";
    } else {
        $template = "index.twig";
    }
    $app->render($template, $locales );

})->name('Home');

// EOF
