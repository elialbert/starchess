@strollz.controller 'StarchessGameCtrl', ['$scope','$interval','$route','game','$routeParams','Restangular','boardService','gameService','$uibModal', ($scope, $interval, $route, game, $routeParams, Restangular, boardService, gameService, $uibModal) ->
  gameService.run_firebase(game.id)
  gameService.setState game
  $scope.game_data = gameService.game_data

  $scope.aiMode = () ->
    @starchessGames = Restangular.all('starchess_games')
    @starchessGames.post({starchess_game: {player2_id:0, join:gameService.game_data.game.id, ai_mode:'normal'}}).then (game) =>
      gameService.game_data.game.extra_state.player2 = 'AI'
      gameService.game_data.game.player2_id = -1

  $scope.get_game_url = () ->
    "http://starchess.elialbert.com/#/StarchessGames/#{gameService.game_data.game.id}"
  @
]
