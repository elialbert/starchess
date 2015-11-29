@strollz.controller 'StarchessGameCtrl', ['$scope','$routeParams','Restangular','boardService', ($scope, $routeParams, Restangular, boardService) ->
  Restangular.one('starchess_games',$routeParams.gameId).get().then (game) ->
    $scope.game = game
    $scope.row_range = _.range(7)
    $scope.col_range = _.range(9)
    

    $scope.need_to_remove_space = (row,col) =>
      if _.indexOf(boardService.remove_spaces[row],col) > -1
        return "removeSpace" 
      else
        return ""
    $scope.get_debug_text = (row,col) =>
      return row + ": " + col + ", " + boardService.space_lookup[row][col]

    console.log game
]