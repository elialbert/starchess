@strollz.controller 'StarchessGamesCtrl', ['$scope', '$location','$window','Restangular','gameService', ($scope, $location,$window, Restangular, gameService) ->
  @starchessGames = Restangular.all('starchess_games')
  $scope.ai_game_data = {}
  $scope.newStarchessGame = (game_variant_type) =>
    @starchessGames.post({starchess_game: {player1_id:1, player2_id:1, game_variant_type: game_variant_type}}).then (game) =>
      $location.path('StarchessGames/'+game.id)
  $scope.joinGame = (gameId) =>
    @starchessGames.post({starchess_game: {player1_id:0, player2_id:0, join:gameId}}).then (game) =>
      $location.path('StarchessGames/'+game.id)
  @starchessGames.getList().then(
    ((games) ->
      $scope.games = games
      new_ai_ai_game()),
    (=>
      new_ai_ai_game())
  )

  new_ai_ai_game = () ->
    Restangular.all('starchess_games').post({starchess_game: {player1_id:-1, player2_id:-1, ai_mode:'both', game_variant_type: 'starchess_nochoose'}}).then (game) =>
      gameService.setState game
      $scope.ai_game_data = gameService.game_data
]
