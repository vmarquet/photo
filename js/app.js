/**
 * Our angular module.
 */
var favoritesApp = angular.module('portfolioApp', ['ngRoute']);


/**
 * Routing configuration for our module.
 */
favoritesApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'templates/index.html'
      }).
      when('/japan', {
        templateUrl: 'templates/japan.html'
      }).
      otherwise({
        redirectTo: '/'
      });
  }
]);

