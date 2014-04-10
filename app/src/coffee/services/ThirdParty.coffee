angular.module('spin.service').service 'ThirdParty', ['$http', '$window', ($http, $window) -> 
    new class ThirdPartyService            
        constructor: ($http, $window) ->
            @url = "http://jeu-d-influences.france5.fr/"

        shareOnFacebook: (url=@url)=>        
            shareUrl = "https://www.facebook.com/sharer/sharer.php?u=#{url}&display=popup"
            $window.open shareUrl, "shareOnFacebook","menubar=no, status=no, scrollbars=no, menubar=no, width=670, height=370"
            yes # https://github.com/angular/angular.js/issues/4853#issuecomment-28491586

        shareOnTwitter: (url=@url)=>
            tweet = "WOW, such game {URL}"
            tweet = tweet.replace "{URL}", @url   
            tweet = encodeURIComponent tweet
            shareUrl = "https://twitter.com/share?&text=#{tweet}&url=&"
            $window.open shareUrl, "shareOnTwitter","menubar=no, status=no, scrollbars=no, menubar=no, width=550, height=380"
            yes # https://github.com/angular/angular.js/issues/4853#issuecomment-28491586

        shareOnGplus: (url=@url)=>
            shareUrl = "https://plus.google.com/share?url=#{url}"
            $window.open shareUrl, "shareOnGplus","menubar=no, status=no, scrollbars=no, menubar=no, width=600, height=600"
            yes # https://github.com/angular/angular.js/issues/4853#issuecomment-28491586
]