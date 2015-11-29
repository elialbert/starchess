@strollz.controller 'StarchessGameCtrl', ['$scope','$routeParams','Restangular', ($scope, $routeParams, Restangular) ->
  Restangular.one('starchess_games',$routeParams.gameId).get().then (game) ->
    $scope.game = game
    $scope.row_range = _.range(7)
    $scope.col_range = _.range(9)
    @remove_spaces = {
      0: [0,1,4,7,8],
      1: [0,1,7,8],
      2: [0,8],
      3: [],
      4: [0,1,7,8],
      5: [0,1,7,8],
      6: [0,1,3,4,5,7,8],
    }

    $scope.need_to_remove_space = (row,col) =>
      if _.indexOf(@remove_spaces[row],col) > -1
        return "removeSpace" 
      else
        return ""
    console.log game
]