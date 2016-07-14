@strollz.directive 'inGameChatBox', () ->
  scope:
    author: '@'
    gameid: '@'
    player2: '@'
  templateUrl: '../templates/chatBox.html'
  controller: 'inGameChatBoxCtrl'

@strollz.controller 'inGameChatBoxCtrl', ($scope, $firebaseArray) ->
  ref = firebase.database().ref("chats/"+$scope.gameid)
  query = ref.orderByChild("timestamp").limitToLast(10)
  $scope.chats = $firebaseArray(query)
  $scope.addMessage = (message) ->
    $scope.chats.$add
      author: $scope.author
      message: message,
      timestamp: firebase.database.ServerValue.TIMESTAMP
    if $scope.player2 == 'AI'
      $scope.chats.$add
        author: 'black'
        message: 'shush, puny human'
        timestamp: firebase.database.ServerValue.TIMESTAMP
    $scope.message=''