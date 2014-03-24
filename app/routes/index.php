<?php
namespace app\routes;

$app->get('/', function() use ($app) {

    # Template's locale variables
    $locales = array();

    $archimade = realpath("../vendor/kit_archimade.php");
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

	$app->render( $app->config("home_template"), $locales );

})->name('Home');

// EOF
