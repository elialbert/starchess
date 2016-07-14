@strollz.directive 'starchessBoard', () ->
  scope: {}
  templateUrl: '../templates/starchessBoard.html'
  controller: 'starchessBoardCtrl'

@strollz.controller 'starchessBoardCtrl', ['$scope', 'boardService', 'gameService', ($scope, boardService, gameService) ->
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range
  $scope.hex_classes = boardService.get_empty_hex_classes()
  $scope.game_data = gameService.game_data
  $scope.$on "boardChange", (event) =>
    @run_hex_classes()

  $scope.do_click = (row,col) =>
    if ($scope.game_data.game.turn != $scope.game_data.game.extra_state.current_user_player) or ($scope.game_data.game.player2_id == 0)
      return
    space_id = boardService.space_id_lookup[row][col]
    if not $scope.game_data.game.selected and (@check_available_moves_key(space_id) != 'available ')
      return
    original_selected = null

    if not $scope.game_data.game.selected
      $scope.game_data.game.selected = space_id
    else if $scope.game_data.game.selected == space_id # unselect selection in play mode
      if $scope.game_data.game.game_variant_type == 'starcraft'
        original_selected = $scope.game_data.game.selected
      else
        $scope.game_data.game.selected = null
    else # choose a space
      original_selected = $scope.game_data.game.selected
      $scope.game_data.game.selected = space_id
    if $scope.game_data.game.mode == 'choose_mode' and $scope.game_data.game.selected
      gameService.handle_choose_mode_choice($scope.game_data.game.selected)
    else if $scope.game_data.game.mode == 'play_mode' and $scope.game_data.game.selected and original_selected
      if $scope.game_data.game.selected in $scope.game_data.game.available_moves[original_selected]
        gameService.handle_play_mode_choice original_selected
      else
        $scope.game_data.game.selected = null
    @run_hex_classes()

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

  @

]
