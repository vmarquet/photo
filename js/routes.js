favoritesApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/portraits', {
        templateUrl: 'content/portraits.html'
      }).
      when('/thaïland', {
        templateUrl: 'content/thaïland.html'
      }).
      when('/japan', {
        templateUrl: 'content/japan.html'
      });
  }
]);
