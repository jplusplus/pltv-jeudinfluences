angular.module("spin.service").factory "Plot", ['$resource', ($resource)-> 
    $resource './data/plot.json'
]

# EOF
