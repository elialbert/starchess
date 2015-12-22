@strollz.factory 'gameService', ['boardService','$uibModal','$rootScope', (boardService, $uibModal, $rootScope) ->
  @loading = false
  @run_firebase = (game_id) ->
    @firebaseRef = new Firebase("https://starchess.firebaseio.com/games/"+game_id)
    @firebaseRef.on 'value', (data) =>
      data = data.val()
      if not data or not @game
        return
      @game.turn = data.turn
      @game.mode = data.mode
      @game_status = boardService.get_game_status data
      @game.chosen_pieces = JSON.parse(data.chosen_pieces or '[]')
      @game.available_moves = JSON.parse(data.available_moves)
      @game.board_state = JSON.parse(data.board_state)
      @game.boardState = @game.board_state
      @game.extra_state.player2 = data.extra_state.player2 if data.extra_state.player2
      @game.player2_id = data.player2_id if data.player2_id
      try
        @set_last_move(data.extra_state)
      catch err
        console.log "SET LAST STATE ERROR"
        console.log err.message
      $rootScope.$broadcast('boardChange')
      @game

  @setState = (game) ->
    @game = game
    @game.game_status = boardService.get_game_status game
    @game.available_moves = JSON.parse(game.available_moves)
    @game.boardState = JSON.parse(game.board_state)
    @game.selected = null # space_id of selected hex
    if @game.extra_state.player2 == "AI"
      @set_last_move(@game.extra_state)
    $rootScope.$broadcast('boardChange')
    return game

  @set_last_move = (data) ->
    if not data or not data.saved_selected_move
      return
    if @game.mode == "choose_mode"
      @game.last_selected_space_id = data.saved_selected_move["space_id"]
    else
      @game.last_selected_space_id = parseInt(JSON.parse(data.saved_selected_move)[1])

  @put_to_server = () ->
    @loading = true
    $rootScope.$broadcast("loading")
    @game.put().then( (response) =>
      @loading = false
      $rootScope.$broadcast("loading")
      @setState response
    (error) =>
      @loading = false
      $rootScope.$broadcast("loading")
      @game.game_status = "#{error.data.error} - #{error.data.error_description}"
    )

  @handle_choose_mode_choice = (selected_space_id) ->
    @game.chosen_pieces = JSON.parse(@game.chosen_pieces) if typeof @game.chosen_pieces is 'string'
    @modalInstance = $uibModal.open {
      controller: 'chooseModeModal',
      templateUrl: 'templates/chooseModeModalTemplate.html'
      resolve: {
        game: () => return @game
      }
    }
    # if piece selected, updated chosen_piece and put to server, update w result
    # otherwise, unselect chosen piece from UI to user can try again
    @modalInstance.result.then(
      (selectedPiece) =>
        @game.chosen_piece = JSON.stringify(
          {piece_type:selectedPiece, space_id:selected_space_id})
        @game.board_state = JSON.stringify(@game.boardState)
        @put_to_server()
      () =>
        @game.selected = null
        $route.reload()
      )

  check_pawn_promotion = (piece_type, space_id, turn) ->
    return piece_type == 'pawn' and space_id in boardService.pawn_promotion_lookup[turn]

  @handle_play_mode_choice = (original_selected) ->
    opposite_color = boardService.get_opposite_color @game.turn
    delete @game.boardState[opposite_color][@game.selected]
    piece_to_move = @game.boardState[@game.turn][original_selected]
    delete @game.boardState[@game.turn][original_selected]
    if @game.game_variant_type == "starcraft"
      if not piece_to_move
        piece_to_move = 'pawn'
      else if @game.boardState[@game.turn][@game.selected]
        piece_to_move = boardService.starcraft_promotion_lookup[@game.boardState[@game.turn][@game.selected]]
    @game.boardState[@game.turn][@game.selected] = piece_to_move
    @game.board_state = JSON.stringify(@game.boardState)
    @game.selected_move = JSON.stringify([original_selected,@game.selected])
    if @game.game_variant_type != "starcraft" and check_pawn_promotion piece_to_move, @game.selected, @game.turn
      @handle_choose_mode_choice(@game.selected)
      @game.selected = null
      return

    @game.selected = null
    @put_to_server()

  return {
    run_firebase: @run_firebase
    game: @game
    setState: @setState
    handle_play_mode_choice: @handle_play_mode_choice
    handle_choose_mode_choice: @handle_choose_mode_choice
    set_last_move: @set_last_move
    put_to_server: @put_to_server
    loading: @loading
  }

]
