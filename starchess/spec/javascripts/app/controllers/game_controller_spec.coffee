#= require spec_helper
describe 'strollz', ->

  describe 'StarchessGameCtrl', ->
    gameCtrl = null
    beforeEach () ->
      game = 
        extra_state: 
          special_state: null
          current_user_player: "white"
        id: 0
        available_moves: "[4,11,17,22,28]"
        board_state: '{"white":{"5":"pawn","12":"pawn","18":"pawn","23":"pawn","29":"pawn"},"black":{"9":"pawn","15":"pawn","20":"pawn","26":"pawn","33":"pawn"}}'
        mode: "choose_mode"
        turn: "white"
      
      Restangular = {}
      gameCtrl = @controller 'StarchessGameCtrl', 
        $scope: @scope,
        $interval: @interval, 
        $route: @route,
        game: game,
        $routeParams: @routeParams,
        Restangular: Restangular,
        boardService: @boardService,
        $uibModal: @uibModal                 

    it 'has choose mode setup correctly', ->
      expect(@scope.game_status).toEqual "This is the board setup phase"

    it 'can get the piece image at a row and col', ->
      image = @scope.get_piece_image(5,2)
      expect(image).toEqual '/assets/chess_pieces/Chess_plt60.png'

    it 'manages classes of hex pieces', ->
      expect(@scope.selected).toBeNull() 
      hex_class_result = @scope.get_hex_class(6,2) # space_id 4
      expect(hex_class_result).toEqual "available "
      @scope.selected = 4
      hex_class_result = @scope.get_hex_class(6,2) # space_id 4
      expect(hex_class_result).toEqual "available selected"
      @scope.selected = null
      
    it 'does stuff on click in choose mode', ->
      @scope.do_click(3,0) # not a choice
      expect(@scope.selected).toBeNull() 
      @scope.do_click(6,2)
      expect(@scope.selected).toEqual(4) 

    it 'also handles clicks in play mode', ->
      @scope.game.mode = 'play_mode'
      @scope.game.board_state = JSON.parse('{"white":{"4":"bishop","8":"queen","17":"rook","30":"king","31":"pawn"},"black":{"5":"queen","9":"pawn","10":"bishop","18":"pawn","20":"rook","33":"pawn","34":"king"}}')
      @scope.boardState = @scope.game.board_state
      @scope.game.turn = 'black'
      @scope.game.extra_state.current_user_player = 'white' # other player
      @scope.available_moves = {5: [6]}
      @scope.selected = null
      @scope.do_click(5,2)
      expect(@scope.selected).toBeNull()

      @scope.game.extra_state.current_user_player = 'black'

      @scope.do_click(5,2) # select queen
      expect(@scope.selected).toEqual(5) # square highlighted
      @scope.do_click(5,2) # unselected
      expect(@scope.selected).toBeNull() # square not highlighted
      @scope.do_click(5,2) 
      expect(@scope.selected).toEqual(5) # square highlighted
      @scope.do_click(3,2) # click forward two - not our one available move as set above
      expect(@scope.selected).toBeNull() # square not highlighted
      @scope.do_click(5,2) 
      expect(@scope.selected).toEqual(5) # square highlighted

      apiSpy = sinon.spy()
      apiSpyThen = sinon.spy()
      apiSpy.then = apiSpyThen
      @scope.game.put = () ->
        apiSpy

      @scope.do_click(4,2) # click forward one - our one available move as set above
      expect(apiSpyThen.called).toBe(true)
      expect(@scope.selected).toBeNull()
      new_state = JSON.parse(@scope.game.board_state)
      expect(new_state['black']['6']).toEqual('queen')
      expect(@scope.game.selected_move).toEqual('[5,6]')

