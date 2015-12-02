#= require spec_helper
describe 'strollz', ->

  describe 'StarchessGameCtrl', ->
    gameCtrl = null
    beforeEach () ->
      game = 
        extra_state: 
          special_state: null
        id: 0
        available_moves: '[]'
        board_state: '{}'

      
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

    it 'tests tests', ->
      expect(true).toEqual(true)