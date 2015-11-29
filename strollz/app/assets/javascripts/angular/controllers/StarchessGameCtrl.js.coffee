@strollz.controller 'StarchessGameCtrl', ['$scope','$routeParams','Restangular','boardService', ($scope, $routeParams, Restangular, boardService) ->
  Restangular.one('starchess_games',$routeParams.gameId).get().then (game) ->
    $scope.game = game
    @boardState = JSON.parse(game.board_state)
    $scope.row_range = boardService.row_range
    $scope.col_range = boardService.col_range
    
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
    $scope.get_debug_text = (row,col) =>
      # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
      # space_id = boardService.space_id_lookup[row][col]
      # return @boardState['white'][space_id] || @boardState['black'][space_id] || 'empty'
      return ''
    console.log game
    console.log boardService.space_rowcol_lookup
]