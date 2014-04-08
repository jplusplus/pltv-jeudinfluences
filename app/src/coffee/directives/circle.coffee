angular.module('spin.directive').directive "circle", [() ->
    restrict: "A"
    replace: false
    scope:
        percentage: "@"
    link: (scope, element, attrs) ->        
        # Get the current id or create one
        id = attrs.id or "dk-circles-id-" + scope.$id        
        # Update element id
        element.attr "id", id

        create = ->
            options =
                id: id
                percentage: parseFloat(attrs.percentage).toFixed(2)
                # Optional
                radius: parseInt(attrs.radius, 10) or 50
                # Optional
                width: parseInt(attrs.width, 10) or 10                
                # Optional
                colors: if attrs.colors then attrs.colors.split(",") else ["#D3B6C6", "#4B253A"]
                # Optional
                duration: parseInt(attrs.duration, 10) or null              
                # Disable number
                number: " "

            # Optional
            options.text = attrs.text if attrs.text?
            # Create the circle with options            
            window.Circles.create options          

        if scope.percentage
            do create
        else
            scope.$watch (->scope.percentage), (-> do circleIt)
]