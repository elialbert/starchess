@strollz.controller 'chooseModeModal', ['$scope','boardService','$uibModalInstance','game', ($scope, boardService, $uibModalInstance, game) ->
  $scope.selected = {}
  $scope.piece_images = boardService.piece_type_to_image[game.turn]
  $scope.pieces = ["queen","rook","bishop","knight","king"]
  $scope.ok =  (piece_type) =>
    $uibModalInstance.close(piece_type);
  
  $scope.cancel = () =>
    $uibModalInstance.dismiss('cancel');
]