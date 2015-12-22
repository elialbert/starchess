@strollz.directive 'starchessBoard', () ->
  scope: {}
  templateUrl: '../templates/starchessBoard.html'
  controller: 'starchessBoardCtrl'

@strollz.controller 'starchessBoardCtrl', ['$scope', 'boardService', 'gameService', ($scope, boardService, gameService) ->
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range
  $scope.hex_classes = boardService.get_empty_hex_classes()
  $scope.$on "boardChange", (event) =>
    @run_hex_classes()
  $scope.$on "loading", (event) =>
    $scope.loading = if gameService.loading then "loading" else ""

  $scope.do_click = (row,col) =>
    if (gameService.game.turn != gameService.game.extra_state.current_user_player) or (gameService.game.player2_id == 0)
      return
    space_id = boardService.space_id_lookup[row][col]
    if not gameService.game.selected and (@check_available_moves_key(space_id) != 'available ')
      return
    original_selected = null

    if not gameService.game.selected
      gameService.game.selected = space_id
    else if gameService.game.selected == space_id # unselect selection in play mode
      if gameService.game.game_variant_type == 'starcraft'
        original_selected = gameService.game.selected
      else
        gameService.game.selected = null
    else # choose a space
      original_selected = gameService.game.selected
      gameService.game.selected = space_id
    if gameService.game.mode == 'choose_mode' and gameService.game.selected
      gameService.handle_choose_mode_choice(gameService.game.selected)
    else if gameService.game.mode == 'play_mode' and gameService.game.selected and original_selected
      if gameService.game.selected in gameService.game.available_moves[original_selected]
        gameService.handle_play_mode_choice original_selected
      else
        gameService.game.selected = null
    @run_hex_classes()

  $scope.need_to_remove_space = (row,col) ->
    if _.indexOf(boardService.remove_spaces[row],col) > -1
      return "removeSpace"
    else
      return ""

  $scope.get_debug_text = (row,col) ->
    # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
    # space_id = boardService.space_id_lookup[row][col]
    # return gameService.game.boardState['white'][space_id] || gameService.game.boardState['black'][space_id] || 'empty'
    return ''

  $scope.get_piece_image = (row,col) ->
    space_id = boardService.space_id_lookup[row][col]
    if piece_type=gameService.game.boardState['white'][space_id]
      color = 'white'
    else if piece_type=gameService.game.boardState['black'][space_id]
      color = 'black'
    else
      color = 'white'
      piece_type = 'empty'
    return boardService.piece_type_to_image[color][piece_type]

  @get_hex_class = (row, col) =>
    hex_class = ''
    space_id = boardService.space_id_lookup[row][col]

    if gameService.game.last_selected_space_id and gameService.game.last_selected_space_id == space_id
      if not gameService.game.selected
        hex_class += 'last_selected '
    if gameService.game.turn != gameService.game.extra_state.current_user_player
      return hex_class

    hex_class += @check_available_moves_key space_id
    if gameService.game.selected == space_id
      hex_class += 'selected '
    if gameService.game.selected and gameService.game.mode == 'play_mode'
      if space_id in gameService.game.available_moves[gameService.game.selected]
        hex_class += 'available_move'
    return hex_class

  @check_available_moves_key = (space_id) ->
    if gameService.game.mode == 'choose_mode'
      if (space_id in gameService.game.available_moves)
        return "available "
    if gameService.game.mode == 'play_mode'
      if not gameService.game.selected
        if gameService.game.available_moves[space_id] and gameService.game.available_moves[space_id].length > 0
          return "available "
    return ''

  @run_hex_classes = () =>
    for row,coldict of boardService.space_id_lookup
      for col, space_id of coldict
        $scope.hex_classes[row][col] = @get_hex_class(row,col)
  @run_hex_classes()

  @

]
