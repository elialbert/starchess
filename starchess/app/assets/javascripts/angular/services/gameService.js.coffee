@strollz.factory 'gameService', ['boardService','$uibModal','$rootScope', (boardService, $uibModal, $rootScope) ->
  game = null
  game_data = {game: game}
  run_firebase = (game_id) ->
    firebaseRef = new Firebase("https://starchess.firebaseio.com/games/"+game_id)
    firebaseRef.on 'value', (data) =>
      data = data.val()
      if not data or not game
        return
      game_data.game.turn = data.turn
      game_data.game.mode = data.mode
      game_data.game.game_status = boardService.get_game_status data
      game_data.game.chosen_pieces = JSON.parse(data.chosen_pieces or '[]')
      game_data.game.available_moves = JSON.parse(data.available_moves)
      game_data.game.board_state = JSON.parse(data.board_state)
      game_data.game.boardState = game_data.game.board_state
      game_data.game.extra_state.player2 = data.extra_state.player2 if data.extra_state.player2
      game_data.game.player2_id = data.player2_id if data.player2_id
      try
        set_last_move(data.extra_state)
      catch err
        console.log "SET LAST STATE ERROR"
        console.log err.message
      $rootScope.$broadcast('boardChange')
      game

  setState = (incoming_game) ->
    game_data.game = incoming_game
    game_data.game.game_status = boardService.get_game_status game_data.game
    game_data.game.available_moves = JSON.parse(game_data.game.available_moves)
    game_data.game.boardState = JSON.parse(game_data.game.board_state)
    console.log "in set state"
    console.log game_data.game.boardState['white']

    game_data.game.selected = null # space_id of selected hex
    if game_data.game.extra_state.player2 == "AI"
      set_last_move(game_data.game.extra_state)
    if !game_data.game.turn
      game_data.game.turn = "white"
    $rootScope.$broadcast('boardChange')

  set_last_move = (data) ->
    if not data or not data.saved_selected_move
      return
    if game_data.game.mode == "choose_mode"
      game_data.game.last_selected_space_id = data.saved_selected_move["space_id"]
    else
      game_data.game.last_selected_space_id = parseInt(JSON.parse(data.saved_selected_move)[1])

  put_to_server = () ->
    game_data.loading = "loading"
    $rootScope.$broadcast("loading")
    console.log "putting with game id #{game_data.game.id}"
    game_data.game.put().then( (response) =>
      game_data.loading = ""
      $rootScope.$broadcast("loading")
      setState response
    (error) =>
      game_data.loading = ""
      $rootScope.$broadcast("loading")
      game_data.game.game_status = "#{error.data.error} - #{error.data.error_description}"
    )

  handle_choose_mode_choice = (selected_space_id) ->
    game_data.game.chosen_pieces = JSON.parse(game_data.game.chosen_pieces) if typeof game_data.game.chosen_pieces is 'string'
    modalInstance = $uibModal.open {
      controller: 'chooseModeModal',
      templateUrl: 'templates/chooseModeModalTemplate.html'
      resolve: {
        game: () => return game_data.game
      }
    }
    # if piece selected, updated chosen_piece and put to server, update w result
    # otherwise, unselect chosen piece from UI to user can try again
    modalInstance.result.then(
      (selectedPiece) =>
        game_data.game.chosen_piece = JSON.stringify(
          {piece_type:selectedPiece, space_id:selected_space_id})
        game_data.game.board_state = JSON.stringify(game_data.game.boardState)
        put_to_server()
      () =>
        game_data.game.selected = null
        $route.reload()
      )

  check_pawn_promotion = (piece_type, space_id, turn) ->
    return piece_type == 'pawn' and space_id in boardService.pawn_promotion_lookup[turn]

  handle_play_mode_choice = (original_selected) ->
    opposite_color = boardService.get_opposite_color game_data.game.turn
    delete game_data.game.boardState[opposite_color][game_data.game.selected]
    piece_to_move = game_data.game.boardState[game_data.game.turn][original_selected]
    delete game_data.game.boardState[game_data.game.turn][original_selected]
    if game_data.game.game_variant_type == "starcraft"
      if not piece_to_move
        piece_to_move = 'pawn'
      else if game_data.game.boardState[game_data.game.turn][game_data.game.selected]
        piece_to_move = boardService.starcraft_promotion_lookup[game_data.game.boardState[game_data.game.turn][game_data.game.selected]]
    game_data.game.boardState[game_data.game.turn][game_data.game.selected] = piece_to_move
    game_data.game.board_state = JSON.stringify(game_data.game.boardState)
    game_data.game.selected_move = JSON.stringify([original_selected,game_data.game.selected])
    if game_data.game.game_variant_type != "starcraft" and check_pawn_promotion piece_to_move, game_data.game.selected, game_data.game.turn
      handle_choose_mode_choice(game_data.game.selected)
      game_data.game.selected = null
      return

    game_data.game.selected = null
    put_to_server()

  return {
    run_firebase: run_firebase
    game_data: game_data
    setState: setState
    handle_play_mode_choice: handle_play_mode_choice
    handle_choose_mode_choice: handle_choose_mode_choice
    set_last_move: set_last_move
    put_to_server: put_to_server
  }

]
