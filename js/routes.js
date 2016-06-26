favoritesApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/japan', {
        templateUrl: 'content/japan.html'
      });
  }
]);
