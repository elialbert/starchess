@strollz.controller 'StarchessGameCtrl', ['$scope','$interval','$route','game','$routeParams','Restangular','boardService','$uibModal', ($scope, $interval, $route, game, $routeParams, Restangular, boardService, $uibModal) ->
  $scope.row_range = boardService.row_range
  $scope.col_range = boardService.col_range
  $scope.hex_classes = boardService.get_empty_hex_classes()

  @run_hex_classes = () =>
    for row,coldict of boardService.space_id_lookup
      for col, space_id of coldict
        $scope.hex_classes[row][col] = @get_hex_class(row,col)    

  @get_hex_class = (row, col) =>
    hex_class = ''
    space_id = boardService.space_id_lookup[row][col]

    if $scope.last_selected_space_id and $scope.last_selected_space_id == space_id
      hex_class += 'last_selected '
    if $scope.game.turn != $scope.game.extra_state.current_user_player
      return hex_class
    
    hex_class += @check_available_moves_key space_id
    if $scope.selected == space_id
      hex_class += 'selected'  
    if $scope.selected and $scope.game.mode == 'play_mode'
      if space_id in $scope.available_moves[$scope.selected]
        hex_class += 'available_move'
    return hex_class

  @check_available_moves_key = (space_id) =>
    if $scope.game.mode == 'choose_mode'
      if (space_id in $scope.available_moves)
        return "available "
    if $scope.game.mode == 'play_mode'
      if not $scope.selected
        if $scope.available_moves[space_id] and $scope.available_moves[space_id].length > 0
          return "available "
    return ''

  @firebaseRef = new Firebase("https://starchess.firebaseio.com/games/"+game.id)
  @firebaseRef.on 'value', (data) =>
    data = data.val()
    if not data or not $scope.game
      return
    $scope.game.turn = data.turn
    $scope.game.mode = data.mode
    $scope.game_status = boardService.get_game_status data
    $scope.game.chosen_pieces = JSON.parse(data.chosen_pieces)
    $scope.available_moves = JSON.parse(data.available_moves)
    $scope.game.board_state = JSON.parse(data.board_state)
    $scope.boardState = $scope.game.board_state
    try
      $scope.set_last_move(data.extra_state)
    catch err
      console.log "SET LAST STATE ERROR"
      console.log err.message
    @run_hex_classes()
    $scope.$apply()

  @setState = (game) =>
    $scope.game = game
    $scope.game_status = boardService.get_game_status game
    $scope.available_moves = JSON.parse(game.available_moves)
    $scope.boardState = JSON.parse(game.board_state)
    $scope.selected = null # space_id of selected hex  
    @run_hex_classes()
  @setState game

  @handle_choose_mode_choice = (selected_space_id) =>
    $scope.game.chosen_pieces = JSON.parse($scope.game.chosen_pieces) if typeof $scope.game.chosen_pieces is 'string'
    @modalInstance = $uibModal.open {
      controller: 'chooseModeModal',
      templateUrl: 'templates/chooseModeModalTemplate.html'
      resolve: {
        game: () -> return $scope.game
      }
    }
    # if piece selected, updated chosen_piece and put to server, update w result
    # otherwise, unselect chosen piece from UI to user can try again
    @modalInstance.result.then(
      (selectedPiece) =>
        $scope.game.chosen_piece = JSON.stringify(
          {piece_type:selectedPiece, space_id:selected_space_id})
        $scope.game.board_state = JSON.stringify($scope.boardState)
        $scope.game.put().then( (response) =>
          @setState response
        (error) =>
          $scope.game_status = "#{error.data.error} - #{error.data.error_description}"
        )
      () =>
        $scope.selected = null
        $route.reload()
      ) 

  @check_pawn_promotion = (piece_type, space_id) =>
    return piece_type == 'pawn' and space_id in boardService.pawn_promotion_lookup[$scope.game.turn]  
  
  @handle_play_mode_choice = (original_selected) =>  
    opposite_color = boardService.get_opposite_color $scope.game.turn
    delete $scope.boardState[opposite_color][$scope.selected]
    piece_to_move = $scope.boardState[$scope.game.turn][original_selected]
    delete $scope.boardState[$scope.game.turn][original_selected]
    $scope.boardState[$scope.game.turn][$scope.selected] = piece_to_move
    $scope.game.board_state = JSON.stringify($scope.boardState)
    $scope.game.selected_move = JSON.stringify([original_selected,$scope.selected])
    if @check_pawn_promotion piece_to_move, $scope.selected
      @handle_choose_mode_choice($scope.selected)
      $scope.selected = null
      return

    $scope.selected = null
    $scope.game.put().then( (response) =>
      @setState response
    (error) =>
      $scope.game_status = "#{error.data.error} - #{error.data.error_description}"
    )
  
  $scope.do_click = (row,col) =>
    if $scope.game.turn != $scope.game.extra_state.current_user_player
      return
    space_id = boardService.space_id_lookup[row][col]
    if not $scope.selected and (@check_available_moves_key(space_id) != 'available ')
      return
    original_selected = null

    if not $scope.selected
      $scope.selected = space_id
    else if $scope.selected == space_id # unselect selection in play mode
      $scope.selected = null
    else # choose a space 
      original_selected = $scope.selected
      $scope.selected = space_id
    if $scope.game.mode == 'choose_mode' and $scope.selected
      @handle_choose_mode_choice($scope.selected)
    else if $scope.game.mode == 'play_mode' and $scope.selected and original_selected
      if $scope.selected in $scope.available_moves[original_selected]
        @handle_play_mode_choice original_selected
      else
        $scope.selected = null
    @run_hex_classes()
  
  $scope.get_piece_image = (row,col) =>
    space_id = boardService.space_id_lookup[row][col]
    if piece_type=$scope.boardState['white'][space_id]
      color = 'white'
    else if piece_type=$scope.boardState['black'][space_id]
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

  $scope.set_last_move = (data) =>
    if not data or not data.saved_selected_move
      return
    if $scope.game.mode == "choose_mode"
      $scope.last_selected_space_id = data.saved_selected_move["space_id"]
    else
      $scope.last_selected_space_id = parseInt(JSON.parse(data.saved_selected_move)[1])
      
  $scope.aiMode = () =>
    @starchessGames = Restangular.all('starchess_games')
    @starchessGames.post({starchess_game: {player2_id:0, join:$scope.game.id, ai_mode:'normal'}}).then (game) =>
      $scope.game.extra_state.player2 = 'AI'
      $scope.game.player2_id = -1
  $scope.get_game_url = () =>
    "http://starchess.upchicago.org/#/StarchessGames/#{$scope.game.id}"    

  $scope.get_debug_text = (row,col) =>
    # return row + ": " + col + ", " + boardService.space_id_lookup[row][col]
    # space_id = boardService.space_id_lookup[row][col]
    # return $scope.boardState['white'][space_id] || $scope.boardState['black'][space_id] || 'empty'
    return ''

]