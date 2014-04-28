angular.module('spin.config').run ['$rootScope', 'User', ($rootScope, User)->  
    $rootScope.user = User
]