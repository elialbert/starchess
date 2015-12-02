#= require application
#= require angular-mocks
#= require sinon
#= require jasmine-sinon

# TO RUN
# bundle exec rake spec:javascript

beforeEach(module('strollz'))

beforeEach inject (_$httpBackend_, _$compile_, $rootScope, $templateCache, $controller, $location, $injector, $timeout, $interval, $route, $routeParams, $uibModal, boardService) ->
  @scope = $rootScope.$new()
  @http = _$httpBackend_
  @compile = _$compile_
  @location = $location
  @controller = $controller
  @injector = $injector
  @timeout = $timeout
  @interval = $interval
  @route = $route
  @routeParams = $routeParams
  @uibModal = $uibModal
  @boardService = boardService
  # @http.whenGET(/^\/templates\//).respond(200,'')
  $templateCache.put('../templates/starchess_games.html', '<div>test</div>')

  @model = (name) =>
    @injector.get(name)
  @eventLoop =
    flush: =>
      @scope.$digest()
  @sandbox = sinon.sandbox.create()

afterEach ->
  @http.resetExpectations()
  @http.verifyNoOutstandingExpectation()