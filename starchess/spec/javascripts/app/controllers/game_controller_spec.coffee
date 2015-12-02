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
