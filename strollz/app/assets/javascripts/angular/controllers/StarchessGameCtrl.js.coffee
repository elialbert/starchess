@strollz.controller 'StarchessGameCtrl', ['$scope','game','$routeParams','Restangular','boardService','$uibModal', ($scope, game, $routeParams, Restangular, boardService, $uibModal) ->
  $scope.game = game
  $scope.available_moves = JSON.parse(game.available_moves)
  console.log game
  @boardState = JSON.parse(game.board_state)
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range
  $scope.selected = null # space_id of selected hex
  
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
    return hex_class

  @check_available_moves_key = (space_id) =>
    if (space_id in $scope.available_moves)
      return "available "
    return ''
      
  $scope.get_debug_text = (row,col) =>
    # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
    # space_id = boardService.space_id_lookup[row][col]
    # return @boardState['white'][space_id] || @boardState['black'][space_id] || 'empty'
    return ''

]