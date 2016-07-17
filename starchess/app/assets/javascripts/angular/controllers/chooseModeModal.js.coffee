@strollz.controller 'chooseModeModal', ['$scope','boardService','$uibModalInstance','game', ($scope, boardService, $uibModalInstance, game) ->
  $scope.selected = {}
  $scope.piece_images = boardService.piece_type_to_image[game.turn]
  if game.mode == "play_mode"
    if game.game_variant_type == "starcraft"
      $scope.pieces = ["rook","bishop","knight"]
    else
      $scope.pieces = ["queen","knight"]
  else
    $scope.pieces = ["queen","rook","bishop","knight","king"]
    $scope.chosen_pieces = []
    if game.chosen_pieces
      $scope.chosen_pieces = game.chosen_pieces[game.turn]
      $scope.pieces = _.difference($scope.pieces, $scope.chosen_pieces)
  $scope.ok =  (piece_type) =>
    $uibModalInstance.close(piece_type);
  
  $scope.cancel = () =>
    $uibModalInstance.dismiss('cancel');
]