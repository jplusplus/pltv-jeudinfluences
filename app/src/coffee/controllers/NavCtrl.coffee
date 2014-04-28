class NavCtrl
    @$inject: ['$scope', 'User', 'ThirdParty']
    constructor: (@scope, @User, @ThirdParty) ->
        @scope.user       = @User
        @scope.thirdParty = @ThirdParty
        @scope.volume     = @User.volume * 100
        @scope.volumeBp   = if @scope.volume is 0 then 50 else @scope.volume
        # True if the volume is on
        @scope.isVolumeOn = => @User.volume > 0
        # Mute or unmute the volume
        @scope.toggleVolume = =>
            if @User.volume is 0
                # Restore old volume value
                @scope.volume = @scope.volumeBp
                # Update the user's volume
                @User.volume = @scope.volume/100
            else
                # Save old volume value
                @scope.volumeBp = @scope.volume
                # Update the user's volume
                @User.volume = @scope.volume = 0


        # Udate the User volume according the scope attribute
        @scope.$watch "volume", (v)=> @User.volume = v/100 if v?    

        @scope.shouldShowSaveButton = @shouldShowSaveButton
        @scope.save = @save

        @_shouldShowSaveButton = yes

        @scope.$watch =>
            User.inGame
        , (newValue, oldValue) =>
            if @User.email? and newValue and not oldValue
                @_shouldShowSaveButton = false

        @scope.$watch 'shouldShowSaveForm', (newValue, oldValue) =>
            if @User.email? and oldValue and not newValue
                @_shouldShowSaveButton = false

    shouldShowSaveButton: =>
        return @User.inGame && @_shouldShowSaveButton

    save: =>
        email = @scope.email
        (@User.associate email)
            .success =>
                @User.email = email
            .error =>
                return

angular.module('spin.controller').controller("NavCtrl", NavCtrl)
# EOF
