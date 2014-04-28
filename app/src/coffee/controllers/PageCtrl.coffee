class PageCtrl
    @$inject: ['$scope', '$location', '$http', 'constant.api']

    constructor: (@scope, @location, @http, @api)->
        @scope.page = no
        @scope.close = @close
        # Watch url's slug to know wich page load
        @scope.$watch (=> @location.search().p ), @loadPage, yes

    loadPage: (slug)=>
        if slug?
            # Load the page from the api
            @http.get(@api.page + "/" + slug).success (data)=> 
                # Update the scope
                @scope.page = data.page
        else
            @scope.page = no

    close: => @location.search("p", null)




angular.module('spin.controller').controller("PageCtrl", PageCtrl)    
# EOF
