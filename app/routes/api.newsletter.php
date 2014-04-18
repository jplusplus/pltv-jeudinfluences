<?php
namespace app\routes;

# -----------------------------------------------------------------------------
#
#    SUBSCRIBE TO THE NEWSLETTER
#
# -----------------------------------------------------------------------------
$app->post('/api/subscribe', function() use ($app) {
    // Angular send post data throught the body in JSON
    $body = json_decode( $app->request()->getBody() );
    $mc_apikey     = $app->config("mailchimp_apikey");
    $mc_id         = $app->config("mailchimp_id");
    $mc_datacenter = $app->config("mailchimp_datacenter");
    $mc_url        = "http://{$mc_datacenter}.api.mailchimp.com/1.3/?method=listSubscribe";
    $params = array(
        'email_address'=> $body->email,
        'apikey'=> $mc_apikey,
        'id' => $mc_id,
        'double_optin' => true,
        'update_existing' => false,
        'replace_interests' => true,
        'send_welcome' => false,
        'email_type' => 'html'
    );
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $mc_url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, urlencode( json_encode($params) ));
    $result = curl_exec($ch);
    curl_close($ch);
    $data = json_decode($result);
    if ( is_object($data) && isset($data->error) ){
        wrong( array("error" => $data->error) );
    } else {
        ok( array("success" => "Look for the confirmation message.") );
    }
});

// EOF