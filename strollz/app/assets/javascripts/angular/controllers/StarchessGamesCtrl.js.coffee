@strollz.controller 'StarchessGamesCtrl', ['$scope', '$location','Restangular', ($scope, $location, Restangular) ->
  @starchessGames = Restangular.all('starchess_games')
  $scope.newGame = () =>
    @starchessGames.post({starchess_game: {player1_id:1, player2_id:1}}).then (game) =>
      $location.path('StarchessGames/'+game.id)
  $scope.joinGame = (gameId) =>
    @starchessGames.post({starchess_game: {player1_id:0, player2_id:0, join:gameId}}).then (game) =>
      $location.path('StarchessGames/'+game.id)
  @starchessGames.getList().then (games) ->
    $scope.games = games.slice().reverse()  
]