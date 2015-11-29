@strollz.controller 'StarchessGamesCtrl', ['$scope','Restangular', ($scope, Restangular) ->
  $scope.test = 'hi'
  Restangular.all('starchess_games').getList().then (games) ->
    $scope.games = games.slice().reverse()  
]