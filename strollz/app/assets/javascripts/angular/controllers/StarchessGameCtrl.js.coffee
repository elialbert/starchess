@strollz.controller 'StarchessGameCtrl', ['$scope','game','$routeParams','Restangular','boardService','$uibModal', ($scope, game, $routeParams, Restangular, boardService, $uibModal) ->
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range

  @setState = (game) =>
    $scope.game = game
    $scope.available_moves = JSON.parse(game.available_moves)
    console.log "setstate: ", game
    @boardState = JSON.parse(game.board_state)
    $scope.selected = null # space_id of selected hex
  
  @setState game

  $scope.do_click = (row,col) =>
    space_id = boardService.space_id_lookup[row][col]
    if not $scope.selected
      $scope.selected = space_id
    else if $scope.selected == space_id
      $scope.selected = null
    else
      $scope.selected = space_id

    if $scope.game.mode == 'choose_mode'
      @modalInstance = $uibModal.open {
        controller: 'chooseModeModal',
        templateUrl: 'templates/chooseModeModalTemplate.html'
        resolve: {
          game: () -> return $scope.game
        }
      }
      @modalInstance.result.then(
        (selectedPiece) =>
          $scope.game.chosen_piece = JSON.stringify(
            {piece_type:selectedPiece, space_id:$scope.selected})
          $scope.game.put().then (response) =>
            @setState response
        () =>
          $scope.selected = null
      )  

  $scope.get_piece_image = (row,col) =>
    space_id = boardService.space_id_lookup[row][col]
    if piece_type=@boardState['white'][space_id]
      color = 'white'
    else if piece_type=@boardState['black'][space_id]
      color = 'black'
    else
      color = 'white'
      piece_type = 'empty'
    return boardService.piece_type_to_image[color][piece_type]

  $scope.need_to_remove_space = (row,col) =>
    if _.indexOf(boardService.remove_spaces[row],col) > -1
      return "removeSpace" 
    else
      return ""

  $scope.get_hex_class = (row, col) =>
    space_id = boardService.space_id_lookup[row][col]
    hex_class = ''
    hex_class += @check_available_moves_key space_id
    if $scope.selected == space_id
      hex_class += 'selected'  
    if $scope.selected
      if space_id in $scope.available_moves[$scope.selected]
        hex_class += 'available_move'
    return hex_class

  @check_available_moves_key = (space_id) =>
    if $scope.game.mode == 'choose_mode'
      if (space_id in $scope.available_moves)
        return "available "
    if $scope.game.mode == 'play_mode'
      if not $scope.selected
        if $scope.available_moves[space_id] and $scope.available_moves[space_id].length > 0
          return "available "
    return ''
      
  $scope.get_debug_text = (row,col) =>
    # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
    # space_id = boardService.space_id_lookup[row][col]
    # return @boardState['white'][space_id] || @boardState['black'][space_id] || 'empty'
    return ''

]