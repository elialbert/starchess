@strollz.controller 'StarchessGameCtrl', ['$scope','$interval','$route','game','$routeParams','Restangular','boardService','gameService','$uibModal', ($scope, $interval, $route, game, $routeParams, Restangular, boardService, gameService, $uibModal) ->
  gameService.run_firebase(game.id)
  $scope.game = gameService.setState game
  $scope.game_status = gameService.game.game_status
  $scope.$on "boardChange", (event) =>
    console.log "got loading event"
    console.log gameService.game.game_status
    $scope.game_status = gameService.game.game_status

  $scope.aiMode = () ->
    @starchessGames = Restangular.all('starchess_games')
    @starchessGames.post({starchess_game: {player2_id:0, join:gameService.game.id, ai_mode:'normal'}}).then (game) =>
      gameService.game.extra_state.player2 = 'AI'
      gameService.game.player2_id = -1

  $scope.get_game_url = () ->
    "http://starchess.upchicago.org/#/StarchessGames/#{gameService.game.id}"
  @
]
