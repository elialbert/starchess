@strollz = angular.module('strollz', ['ngRoute'])

# This routing directive tells Angular about the default
# route for our application. The term "otherwise" here
# might seem somewhat awkward, but it will make more
# sense as we add more routes to our application.
@strollz.config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/StarchessGames/', {
      templateUrl: '../templates/starchess_games.html',
      controller: 'StarchessGamesCtrl'
    })
  $routeProvider.otherwise({
      templateUrl: '../templates/home.html',
      controller: 'HomeCtrl'
    }) 
])