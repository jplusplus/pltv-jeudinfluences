angular.module('spin.config').config ['$sceDelegateProvider', ($sceDelegateProvider)->  
    $sceDelegateProvider.resourceUrlWhitelist ['self', 'http://*.dailymotion.com/**', 'https://*.dailymotion.com/**']
]