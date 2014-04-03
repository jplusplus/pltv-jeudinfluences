angular.module('spin.constant',  [])
angular.module('spin.animation', ['ngAnimate', 'spin.constant'])
angular.module('spin.config',    ['ngRoute',    'spin.constant'])
angular.module('spin.controller',['ngResource', 'spin.constant'])
angular.module('spin.directive', ['ngResource', 'spin.constant'])
angular.module('spin.filter',    ['ngResource', 'spin.constant'])
angular.module('spin.template',  ['ngRoute'])
angular.module('spin.service',   ['ngResource', 'LocalStorageModule', 'spin.constant'])

app = angular.module 'spin', [
    # Angular dependencies
    "ngRoute"
    "ngResource"
    "ngAnimate"
    "ngSanitize"
    # External dependencies
    "btford.markdown"
    # Internal dependencies
    "spin.constant"
    "spin.animation"
    "spin.config"
    "spin.filter"
    "spin.service"
    "spin.template"
    "spin.directive"
]
# EOF