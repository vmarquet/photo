/**
 * Our angular module.
 */
var portfolioApp = angular.module('portfolioApp', ['ngRoute']);


/**
 * Routing configuration for our module.
 */
angular.module('portfolioApp').config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'content/index.html'
      }).
      when('/contact', {
        templateUrl: 'content/contact.html'
      }).
      otherwise({
        redirectTo: '/'
      });
  }
]);

