var ChapterCtrl, MainCtrl, SceneCtrl, app,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('spin.controller', ['ngResource']);

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
  ChapterCtrl.$inject = ['$scope', 'Plot', 'User'];

  function ChapterCtrl(scope, Plot, User) {
    var _this = this;
    this.scope = scope;
    this.Plot = Plot;
    this.User = User;
    this.scope.shouldShowChapter = function(chapter) {
      return 1 * chapter.id === _this.User.chapter;
    };
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
  }

  return MainCtrl;

})();

SceneCtrl = (function() {
  SceneCtrl.$inject = ['$scope', 'Plot', 'User'];

  function SceneCtrl(scope, Plot, User) {
    var SEQUENCE_TYPE_BLOCKING, SEQUENCE_TYPE_WITH_NEXT,
      _this = this;
    this.scope = scope;
    this.Plot = Plot;
    this.User = User;
    SEQUENCE_TYPE_WITH_NEXT = ["dialogue", "narrative", "video", "notification"];
    SEQUENCE_TYPE_BLOCKING = ["dialogue", "narrative", "voixoff", "video", "notification", "choice"];
    this.scope.shouldShowScene = function(scene) {
      return 1 * scene.id === _this.User.scene;
    };
    this.scope.shouldShowSequence = function(idx) {
      return 1 * idx === _this.User.sequence;
    };
    this.scope.shouldShowNext = function(sequence) {
      return SEQUENCE_TYPE_WITH_NEXT.indexOf(sequence.type.toLowerCase()) > -1;
    };
    this.scope.goToNextSequence = this.User.nextSequence;
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

angular.module("spin.service").factory("Plot", [
  '$http', function($http) {
    var Plot;
    return new (Plot = (function() {
      function Plot() {
        this.sequence = __bind(this.sequence, this);
        this.scene = __bind(this.scene, this);
        this.chapter = __bind(this.chapter, this);
        var _this = this;
        this.chapters = [];
        $http.get("/api/plot").success(function(chapters) {
          return _this.chapters = chapters;
        });
        return this;
      }

      Plot.prototype.chapter = function(chapterId) {
        return _.find(this.chapters || [], function(chapter) {
          return 1 * chapter.id === 1 * chapterId;
        });
      };

      Plot.prototype.scene = function(chapterId, sceneId) {
        var chapter;
        chapter = this.chapter(chapterId) || {};
        return _.find(chapter.scenes || [], function(scene) {
          return 1 * scene.id === 1 * sceneId;
        });
      };

      Plot.prototype.sequence = function(chapterId, sceneId, sequenceIdx) {
        var scene;
        scene = this.scene(chapterId, sceneId) || {
          sequence: []
        };
        return scene.sequence[sequenceIdx];
      };

      return Plot;

    })());
  }
]);

angular.module("spin.service").factory("User", [
  'Plot', function(Plot) {
    var User;
    return new (User = (function() {
      function User() {
        this.nextSequence = __bind(this.nextSequence, this);
        this.chapter = 1;
        this.scene = 1;
        this.sequence = 0;
        this.ubm = ~~(Math.random() * 100);
        this.trust = ~~(Math.random() * 100);
        this.stress = ~~(Math.random() * 100);
        return this;
      }

      User.prototype.nextSequence = function() {
        if (Plot.sequence(this.chapter, this.scene, this.sequence + 1) != null) {
          return ++this.sequence;
        } else if (Plot.scene(this.chapter, this.scene + 1) != null) {
          this.sequence = 0;
          return ++this.scene;
        } else if (Plot.chapter(this.chapter + 1) != null) {
          this.sequence = 0;
          this.scene = Plot.chapter(this.chapter + 1).scene[0].id;
          return ++this.chapter;
        }
      };

      return User;

    })());
  }
]);
