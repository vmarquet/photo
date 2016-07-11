favoritesApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/displays', {
        templateUrl: 'content/displays.html'
      }).
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
