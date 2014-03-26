var ChapterCtrl, MainCtrl, NavCtrl, SceneCtrl, app,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('spin.controller', ['ngResource']);

angular.module('spin.config', ['ngResource']);

angular.module('spin.directive', ['ngResource']);

angular.module('spin.filter', ['ngResource']);

angular.module('spin.service', ['ngResource', 'LocalStorageModule']);

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
  MainCtrl.$inject = ['$scope', 'Plot', 'User', 'Sound'];

  function MainCtrl(scope, Plot, User, Sound) {
    this.scope = scope;
    this.Plot = Plot;
    this.User = User;
    this.Sound = Sound;
    this.scope.plot = this.Plot;
    this.scope.user = this.User;
    this.scope.sound = this.Sound;
  }

  return MainCtrl;

})();

NavCtrl = (function() {
  NavCtrl.$inject = ['$scope', 'User'];

  function NavCtrl(scope, User) {
    var _this = this;
    this.scope = scope;
    this.User = User;
    this.scope.volume = this.User.volume * 100;
    this.scope.$watch("volume", function(v) {
      if (v != null) {
        return _this.User.volume = v / 100;
      }
    });
  }

  return NavCtrl;

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
      return true || SEQUENCE_TYPE_WITH_NEXT.indexOf(sequence.type.toLowerCase()) > -1;
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

angular.module("spin.service").factory("Sound", [
  'User', 'Plot', '$rootScope', function(User, Plot, $rootScope) {
    var Sound;
    return new (Sound = (function() {
      function Sound() {
        this.updateVolume = __bind(this.updateVolume, this);
        this.startSequence = __bind(this.startSequence, this);
        this.startScene = __bind(this.startScene, this);
        var _this = this;
        $rootScope.$watch((function() {
          return Plot.chapters || User.scene;
        }), function() {
          return _this.startScene();
        });
        $rootScope.$watch((function() {
          return User.sequence;
        }), function() {
          return _this.startSequence();
        });
        $rootScope.$watch((function() {
          return User.volume;
        }), this.updateVolume);
      }

      Sound.prototype.startScene = function(chapter, scene) {
        var tracks,
          _this = this;
        if (chapter == null) {
          chapter = User.chapter;
        }
        if (scene == null) {
          scene = User.scene;
        }
        if ((scene != null) && Plot.chapters.length) {
          scene = Plot.scene(chapter, scene);
          tracks = [scene.decor[0].soundtrack];
          if ((this.soundtrack == null) || !angular.equals(this.soundtrack.urls(), tracks)) {
            this.soundtrack = new Howl({
              urls: tracks,
              loop: true,
              buffer: true,
              volume: 0
            });
            return this.soundtrack.play(function() {
              return _this.soundtrack.fade(0, User.volume, 2000);
            });
          }
        }
      };

      Sound.prototype.startSequence = function(chapter, scene, sequence) {
        var tracks,
          _this = this;
        if (chapter == null) {
          chapter = User.chapter;
        }
        if (scene == null) {
          scene = User.scene;
        }
        if (sequence == null) {
          sequence = User.sequence;
        }
        if (sequence != null) {
          sequence = Plot.sequence(chapter, scene, sequence);
          if (sequence.type === "voixoff") {
            tracks = [sequence.body];
            if ((this.voicetrack == null) || !angular.equals(this.voicetrack.urls(), tracks)) {
              this.voicetrack = new Howl({
                urls: tracks,
                loop: false,
                buffer: true,
                volume: 0
              });
              if (this.soundtrack != null) {
                this.soundtrack.fade(this.soundtrack.volume(), User.volume / 2);
              }
              return this.voicetrack.play(function() {
                return _this.voicetrack.fade(0, User.volume, 2000);
              });
            }
          } else if (this.voicetrack != null) {
            if (this.soundtrack != null) {
              this.soundtrack.fade(this.soundtrack.volume(), User.volume);
            }
            return this.voicetrack.fade(this.voicetrack.volume(), 0, 2000, function() {
              return _this.voicetrack.stop();
            });
          }
        }
      };

      Sound.prototype.updateVolume = function(volume) {
        if (volume != null) {
          switch (true) {
            case (this.voicetrack != null) && (this.soundtrack != null):
              this.voicetrack.volume(volume);
              return this.soundtrack.volume(volume / 2);
            case this.voicetrack != null:
              return this.voicetrack.volume(volume);
            case this.soundtrack != null:
              return this.soundtrack.volume(volume);
          }
        }
      };

      return Sound;

    })());
  }
]);

angular.module("spin.service").factory("User", [
  'Plot', 'localStorageService', '$rootScope', function(Plot, localStorageService, $rootScope) {
    var User;
    return new (User = (function() {
      function User() {
        this.nextSequence = __bind(this.nextSequence, this);
        this.updateLocalStorage = __bind(this.updateLocalStorage, this);
        var master,
          _this = this;
        master = localStorageService.get("user") || {};
        this.token = master.token || null;
        this.email = master.email || null;
        this.volume = master.volume || 0.5;
        this.chapter = 1;
        this.scene = 1;
        this.sequence = 0;
        this.ubm = ~~(Math.random() * 100);
        this.trust = ~~(Math.random() * 100);
        this.stress = ~~(Math.random() * 100);
        $rootScope.$watch((function() {
          return _this;
        }), this.updateLocalStorage, true);
        return this;
      }

      User.prototype.updateLocalStorage = function(user) {
        if (user == null) {
          user = this;
        }
        if (user != null) {
          return localStorageService.set("user", user);
        }
      };

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
