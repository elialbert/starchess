@strollz = angular.module('strollz', ['ngRoute','restangular'])

@strollz.config(['RestangularProvider', (RestangularProvider) ->
  RestangularProvider.setBaseUrl('/1')
  # add a response intereceptor
  RestangularProvider.addResponseInterceptor( (data, operation, what, url, response, deferred) ->
    if operation == "getList"
      extractedData = data.response
      extractedData.count = data.count
      extractedData.pagination = data.pagination
    else 
      extractedData = data.response
    return extractedData
  )
])
@strollz.config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/StarchessGames/', {
      templateUrl: '../templates/starchess_games.html',
      controller: 'StarchessGamesCtrl'
    })
  $routeProvider.when('/StarchessGames/:gameId', {
      templateUrl: '../templates/starchess_game.html',
      controller: 'StarchessGameCtrl'
    })
  $routeProvider.otherwise({
      templateUrl: '../templates/home.html',
      controller: 'HomeCtrl'
    }) 
])