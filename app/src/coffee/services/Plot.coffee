angular.module("spin.services", ['ngResource']).factory "Plot", ['$resource', ($resource)-> 
    $resource './data/plot.json'
]

# EOF
