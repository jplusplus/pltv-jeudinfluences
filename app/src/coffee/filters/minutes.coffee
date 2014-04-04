angular.module("spin.filter").filter "minutes", ->
    (input)->    
        input   = 0 if isNaN input    
        # Calculate repartition 
        minutes = Math.floor input/60
        seconds = Math.round input - minutes * 60
        # Add 0 to number under 10
        minutes = ('0' + minutes).slice(-2)
        seconds = ('0' + seconds).slice(-2)
        # Return the string
        "#{minutes}:#{seconds}"
# EOF