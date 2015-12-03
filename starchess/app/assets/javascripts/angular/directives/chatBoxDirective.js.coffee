@strollz.directive 'inGameChatBox', () ->
  scope:
    author: '@'
    gameid: '@'
  templateUrl: '../templates/chatBox.html'
  controller: 'inGameChatBoxCtrl'

@strollz.controller 'inGameChatBoxCtrl', ($scope, $firebaseArray) ->
  ref = new Firebase("https://starchess.firebaseio.com/chats/"+$scope.gameid)
  query = ref.orderByChild("timestamp").limitToLast(10)
  $scope.chats = $firebaseArray(query)
  $scope.addMessage = (message) ->
    $scope.chats.$add
      author: $scope.author
      message: message,
      timestamp: Firebase.ServerValue.TIMESTAMP
    $scope.message=''