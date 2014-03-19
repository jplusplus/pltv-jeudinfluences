<?php
namespace app\routes;

$app->get('/wait', function() use ($app) {    

    $app->view()->appendData(
        array(
            'viewName'=> 'Wait'
        )
    );

    $app->render('wait.twig');

})->name('Wait');