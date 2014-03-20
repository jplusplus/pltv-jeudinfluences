class Plot
    @$inject: ['$http']    
    constructor: ($http)->
        @chapters = []
        # Get plot
        $http.get("/api/plot").success (chapters)=> @chapters = chapters
        return @

angular.module("spin.service").factory "Plot", Plot
# EOF