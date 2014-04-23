angular.module('spin.service').factory 'KeyboardCommands', ->
    new class KeyboardCommands
        constructor: ->
            @list = {}

        register: (cmd_key, cmd)=>
            bind = (key, cmd)=>
                @list[key] = cmd

            if typeof cmd_key is typeof []
                _.each cmd_key, (sub_key)-> bind(sub_key, cmd)
            else
                bind(cmd_key, cmd)
        
        unregister: (cmd_key)=>
            unbind = (key)=>
                if @list[key]?
                    @list[key] = undefined
                    delete @list[key]

            if typeof cmd_key is typeof []
                _.each cmd_key, (sub_key)-> unbind(sub_key)
            else
                unbind(cmd_key)

        listCommands: => @list

        get: (key)=> @listCommands()[key]



        
