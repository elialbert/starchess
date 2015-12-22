#= require spec_helper
describe 'strollz', ->

  describe 'StarchessGameCtrl', ->
    # gameCtrl = null
    beforeEach () ->
      @game =
        extra_state:
          special_state: null
          current_user_player: "white"
        id: 0
        available_moves: "[4,11,17,22,28]"
        board_state: '{"white":{"5":"pawn","12":"pawn","18":"pawn","23":"pawn","29":"pawn"},"black":{"9":"pawn","15":"pawn","20":"pawn","26":"pawn","33":"pawn"}}'
        mode: "choose_mode"
        turn: "white"

      Restangular = {}
      @gameCtrl = @controller 'StarchessGameCtrl',
        $scope: @scope,
        $interval: @interval,
        $route: @route,
        game: @game,
        $routeParams: @routeParams,
        Restangular: Restangular,
        boardService: @boardService,
        gameService: @gameService,
        $uibModal: @uibModal

      @boardCtrl = @controller 'starchessBoardCtrl',
        $scope: @scope2,
        boardService: @boardService,
        gameService: @gameService

    it 'has choose mode setup correctly', ->
      expect(@scope.game.game_status).toEqual "This is the board setup phase"

    it 'can get the piece image at a row and col', ->
      image = @scope2.get_piece_image(5,2)
      expect(image).toEqual '/assets/chess_pieces/Chess_plt60.png'

    it 'manages classes of hex pieces', ->
      expect(@gameService.game.selected).toBeNull()
      hex_class_result = @boardCtrl.get_hex_class(6,2) # space_id 4
      expect(hex_class_result).toEqual "available "
      @gameService.game.selected = 4
      hex_class_result = @boardCtrl.get_hex_class(6,2) # space_id 4
      expect(hex_class_result).toEqual "available selected "
      @gameService.game.selected = null

    it 'does stuff on click in choose mode', ->
      @gameService.game = @game
      @scope2.do_click(3,0) # not a choice
      expect(@gameService.game.selected).toBeNull()
      @scope2.do_click(6,2)
      expect(@gameService.game.selected).toEqual(4)

    it 'also handles clicks in play mode', ->
      @gameService.game = @game
      @gameService.game.mode = 'play_mode'
      @gameService.game.board_state = JSON.parse('{"white":{"4":"bishop","8":"queen","17":"rook","30":"king","31":"pawn"},"black":{"5":"queen","9":"pawn","10":"bishop","18":"pawn","20":"rook","33":"pawn","34":"king"}}')
      @gameService.game.boardState = @gameService.game.board_state
      @gameService.game.turn = 'black'
      @gameService.game.extra_state.current_user_player = 'white' # other player
      @gameService.game.available_moves = {5: [6]}
      @gameService.game.selected = null
      @scope2.do_click(5,2)
      expect(@gameService.game.selected).toBeNull()

      @gameService.game.extra_state.current_user_player = 'black'

      @scope2.do_click(5,2) # select queen
      expect(@gameService.game.selected).toEqual(5) # square highlighted
      @scope2.do_click(5,2) # unselected
      expect(@gameService.game.selected).toBeNull() # square not highlighted
      @scope2.do_click(5,2)
      expect(@gameService.game.selected).toEqual(5) # square highlighted
      @scope2.do_click(3,2) # click forward two - not our one available move as set above
      expect(@gameService.game.selected).toBeNull() # square not highlighted
      @scope2.do_click(5,2)
      expect(@gameService.game.selected).toEqual(5) # square highlighted

      apiSpy = sinon.spy()
      apiSpyThen = sinon.spy()
      apiSpy.then = apiSpyThen
      @gameService.game.put = () ->
        apiSpy

      @scope2.do_click(4,2) # click forward one - our one available move as set above
      expect(apiSpyThen.called).toBe(true)
      expect(@gameService.game.selected).toBeNull()
      new_state = JSON.parse(@gameService.game.board_state)
      expect(new_state['black']['6']).toEqual('queen')
      expect(@gameService.game.selected_move).toEqual('[5,6]')

