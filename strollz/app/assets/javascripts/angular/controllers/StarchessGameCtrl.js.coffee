@strollz.controller 'StarchessGameCtrl', ['$scope','$routeParams','Restangular', ($scope, $routeParams, Restangular) ->
  Restangular.one('starchess_games',$routeParams.gameId).get().then (game) ->
    $scope.game = game
    console.log game
]