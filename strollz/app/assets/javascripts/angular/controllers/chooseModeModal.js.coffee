@strollz.controller 'chooseModeModal', ['$scope','boardService','$uibModalInstance','game', ($scope, boardService, $uibModalInstance, game) ->
  $scope.selected = {}
  console.log 'popping modal', $uibModalInstance
  $scope.ok =  () =>
    $uibModalInstance.close($scope.selected.item);
  
  $scope.cancel = () =>
    $uibModalInstance.dismiss('cancel');
]