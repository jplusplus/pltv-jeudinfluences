angular.module("spin.filter").filter "media", [ 'constant.settings', (settings)->
    (input) -> settings.mediaUrl + input
]