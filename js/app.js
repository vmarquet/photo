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
        templateUrl: 'content/index.html'
      }).
      otherwise({
        redirectTo: '/'
      });
  }
]);

