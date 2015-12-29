@strollz.directive 'aistarchessBoard', () ->
  scope: {}
  templateUrl: '../templates/starchessBoard.html'
  controller: 'aistarchessBoardCtrl'

@strollz.controller 'aistarchessBoardCtrl', ['$scope', 'boardService', 'gameService', '$interval','Restangular', ($scope, boardService, gameService, $interval, Restangular) ->
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range
  $scope.hex_classes = boardService.get_empty_hex_classes()
  $scope.game_data = gameService.game_data
  $scope.num_moves = 0
  $scope.$on "boardChange", (event) =>
    @run_hex_classes()

  $scope.run = () =>
    @interv = $interval($scope.do_move, 500)

  $scope.do_move = () =>
    console.log "in do move"
    console.log $scope.game_data.game.boardState['white']
    $scope.num_moves += 1
    console.log "running move num #{$scope.num_moves}"
    gameService.put_to_server()
    console.log $scope.game_data.game.mode
    if $scope.game_data.game.mode == "done" or $scope.num_moves > 15
      console.log "CANCELLING - new game"
      $scope.num_moves = 0
      $interval.cancel(@interv)
      Restangular.all('starchess_games').post({starchess_game: {player1_id:-1, player2_id:-1, ai_mode:'both'}}).then (game) =>
        gameService.game_data = {game: game}
        gameService.setState game
        $scope.game_data = gameService.game_data
        $scope.run()

  $scope.need_to_remove_space = (row,col) ->
    if _.indexOf(boardService.remove_spaces[row],col) > -1
      return "removeSpace"
    else
      return ""

  $scope.get_debug_text = (row,col) ->
    # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
    # space_id = boardService.space_id_lookup[row][col]
    # return $scope.game_data.game.boardState['white'][space_id] || $scope.game_data.game.boardState['black'][space_id] || 'empty'
    return ''

  $scope.get_piece_image = (row,col) ->
    space_id = boardService.space_id_lookup[row][col]

    if piece_type=$scope.game_data.game.boardState['white'][space_id]
      color = 'white'
    else if piece_type=$scope.game_data.game.boardState['black'][space_id]
      color = 'black'
    else
      color = 'white'
      piece_type = 'empty'
    return boardService.piece_type_to_image[color][piece_type]

  @get_hex_class = (row, col) =>
    hex_class = ''
    space_id = boardService.space_id_lookup[row][col]

    if $scope.game_data.game.last_selected_space_id and $scope.game_data.game.last_selected_space_id == space_id
      if not $scope.game_data.game.selected
        hex_class += 'last_selected '
    if $scope.game_data.game.turn != $scope.game_data.game.extra_state.current_user_player
      return hex_class

    hex_class += @check_available_moves_key space_id
    if $scope.game_data.game.selected == space_id
      hex_class += 'selected '
    if $scope.game_data.game.selected and $scope.game_data.game.mode == 'play_mode'
      if space_id in $scope.game_data.game.available_moves[$scope.game_data.game.selected]
        hex_class += 'available_move'
    return hex_class

  @check_available_moves_key = (space_id) ->
    if $scope.game_data.game.mode == 'choose_mode'
      if (space_id in $scope.game_data.game.available_moves)
        return "available "
    if $scope.game_data.game.mode == 'play_mode'
      if not $scope.game_data.game.selected
        if $scope.game_data.game.available_moves[space_id] and $scope.game_data.game.available_moves[space_id].length > 0
          return "available "
    return ''

  @run_hex_classes = () =>
    for row,coldict of boardService.space_id_lookup
      for col, space_id of coldict
        $scope.hex_classes[row][col] = @get_hex_class(row,col)
  @run_hex_classes()
  $scope.run()
  @

]
