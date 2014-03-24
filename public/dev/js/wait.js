var WaitCtrl, app,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

app = angular.module('spin', ["ngAnimate"]);

app.config([
  '$interpolateProvider', function($interpolateProvider) {
    $interpolateProvider.startSymbol('[[');
    return $interpolateProvider.endSymbol(']]');
  }
]);

WaitCtrl = (function() {
  WaitCtrl.$inject = ["$scope", "$http"];

  function WaitCtrl(scope, http) {
    this.scope = scope;
    this.http = http;
    this.submit = __bind(this.submit, this);
    this.scope.submit = this.submit;
  }

  WaitCtrl.prototype.submit = function() {
    var _this = this;
    return this.http.post("/api/subscribe", {
      email: this.scope.email
    }).success(function() {
      return _this.scope.success = true;
    }).error(function() {
      return _this.scope.error = true;
    });
  };

  return WaitCtrl;

})();
