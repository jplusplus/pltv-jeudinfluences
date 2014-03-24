var ChapterCtrl, MainCtrl, Plot, SceneCtrl, User, app;

angular.module('spin.config', ['ngResource']);

angular.module('spin.directive', ['ngResource']);

angular.module('spin.filter', ['ngResource']);

angular.module('spin.service', ['ngResource']);

app = angular.module('spin', ["ngRoute", "ngResource", "ngAnimate", "spin.filter", "spin.service", "spin.directive"]);

app.config([
  '$interpolateProvider', '$routeProvider', function($interpolateProvider, $routeProvider) {
    $interpolateProvider.startSymbol('[[');
    $interpolateProvider.endSymbol(']]');
    return $routeProvider.when("/", {
      templateUrl: "partials/main.html",
      controller: "MainCtrl"
    }).otherwise({
      redirectTo: "/"
    });
  }
]);

ChapterCtrl = (function() {
  ChapterCtrl.$inject = ['$scope'];

  function ChapterCtrl(scope) {
    this.scope = scope;
  }

  return ChapterCtrl;

})();

MainCtrl = (function() {
  MainCtrl.$inject = ['$scope', 'Plot', 'User'];

  function MainCtrl(scope, Plot, User) {
    this.scope = scope;
    this.Plot = Plot;
    this.User = User;
    this.scope.plot = this.Plot;
    this.scope.user = this.User;
    console.log(this.User.chapter);
  }

  return MainCtrl;

})();

SceneCtrl = (function() {
  SceneCtrl.$inject = ['$scope'];

  function SceneCtrl(scope) {
    this.scope = scope;
  }

  return SceneCtrl;

})();

angular.module('spin.directive').directive("screenHeight", [
  "$window", function($window) {
    return function(scope, element, attrs) {
      var ev, resize;
      ev = "screenHeight resize";
      resize = function() {
        element.css("height", $window.innerHeight);
        if (!isNaN(attrs.screenHeight)) {
          return element.css("min-height", 1 * attrs.screenHeight);
        }
      };
      resize();
      angular.element($window).bind(ev, resize);
      return scope.$on('$destroy', function() {
        return angular.element($window).unbind(ev);
      });
    };
  }
]);

angular.module("spin.filter", []).filter("checkmark", function() {
  return function(input) {
    if (input) {
      return '\u2713';
    } else {
      return '\u2718';
    }
  };
});

Plot = (function() {
  Plot.$inject = ['$http'];

  function Plot($http) {
    var _this = this;
    this.chapters = [];
    $http.get("/api/plot").success(function(chapters) {
      return _this.chapters = chapters;
    });
    return this;
  }

  return Plot;

})();

angular.module("spin.service").factory("Plot", Plot);

User = (function() {
  User.$inject = ['$http', 'Plot'];

  function User(Plot) {
    this.Plot = Plot;
    this.chapter = 1;
    return this;
  }

  return User;

})();

angular.module("spin.service").factory("User", User);
