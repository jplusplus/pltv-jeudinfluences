class NavCtrl
    @$inject: ['$scope', 'User', 'ThirdParty']
    constructor: (@scope, @User, @ThirdParty) ->
        @scope.thirdParty = @ThirdParty
        @scope.volume     = @User.volume * 100
        # True if the volume is on
        @scope.isVolumeOn = => @User.volume > 0
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
