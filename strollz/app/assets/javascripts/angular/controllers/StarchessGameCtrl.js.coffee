@strollz.controller 'StarchessGameCtrl', ['$scope','$routeParams','Restangular','boardService', ($scope, $routeParams, Restangular, boardService) ->
  Restangular.one('starchess_games',$routeParams.gameId).get().then (game) ->
    $scope.game = game
    $scope.boardState = JSON.parse(game.board_state)
    $scope.row_range = boardService.row_range
    $scope.col_range = boardService.col_range
    
    $scope.get_piece_image = (row,col) =>


    $scope.need_to_remove_space = (row,col) =>
      if _.indexOf(boardService.remove_spaces[row],col) > -1
        return "removeSpace" 
      else
        return ""
    $scope.get_debug_text = (row,col) =>
      return row + ": " + col + ", " + boardService.space_id_lookup[row][col]

    console.log game
    console.log boardService.space_rowcol_lookup
]