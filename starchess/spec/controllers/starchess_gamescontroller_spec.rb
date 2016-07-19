require "spec_helper"
require 'starchess/game'

describe StarchessGamesController, :type => :controller do  
  u1,u2=nil

  def make_choose_update response, turn, piece_type, space_id, game_id
    return response if response.parsed_body['response'].nil?
    board_state = response.parsed_body['response']['board_state']
    data = {"starchess_game" => {"board_state" => board_state,
      "turn" => turn,
      "chosen_piece" => '{"piece_type": "'+piece_type.to_s+'", "space_id": '+space_id.to_s+'}'},
      "id" => game_id, "version" => 1}
    patch :update, data
  end 

  def make_play_update board_state, selected, turn, game_id
    data = {"starchess_game" => {"board_state" => board_state,
        "turn" => turn,
        "selected_move" => selected},
        "id" => game_id, "version" => 1}
    patch :update, data
  end

  before do
    User.delete_all
    StarchessGame.delete_all
    u1 = User.create({
      :email => 'test1@test.com',
      :first_name => 'testname1',
      :lat => 41.928249,
      :lng => -87.717069
    })
    sign_in :user, u1
    u2 = User.create({
      :email => 'test2@test.com',
      :first_name => 'testname2',
      :lat => 40.92680,
      :lng => -86.718957
    })

  end

  it "can create a new starchess game" do
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u2.id}, "version" => 1}
    response = post :create, data
    expect(response.parsed_body['response']['mode']).to eq('choose_mode')
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    expect(board_state['white']['5']).to eq('pawn')
    expect(response.parsed_body['response']['available_moves']).to eq("[4,11,17,22,28]")
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u2.id,
      "game_variant_type" => "starcraft"
      }, "version" => 1}
    response = post :create, data
    expect(response.parsed_body['response']['game_variant_type']).to eq('starcraft')

  end

  it "can play a whole game in AI mode" do
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => 0}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']
    sign_in :user, u1

    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => 0, "join" => game_id, "ai_mode" => "normal"}, "version" => 1}
    response = post :create, data

    g1 = StarchessGame.find(game_id)
    expect(g1.mode).to eq('choose_mode')
    expect(g1.ai_mode).to eq('normal')
    expect(g1.player2_id).to eq(-1)
    data = {"starchess_game" => {"board_state" => 
      '{"white" : {"5":"pawn", "12":"pawn", "18":"pawn", "23":"pawn", "29":"pawn"}, 
      "black" : {"9":"pawn", "15":"pawn", "20":"pawn", "26":"pawn", "33":"pawn"}}', 
      "turn" => "white",
      "chosen_piece" => '{"piece_type" : "rook", "space_id" : 4}'}, 
      "id" => g1.id, "version" => 1}
    response = patch :update, data

    expect(response.parsed_body['response']['turn']).to eq('white')
    expect(response.parsed_body['response']['mode']).to eq('choose_mode')
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    response=make_choose_update response, "white", "bishop", 11, g1.id
    response=make_choose_update response, "white", "knight", 17, g1.id
    response=make_choose_update response, "white", "king", 22, g1.id
    response=make_choose_update response, "white", "queen", 28, g1.id

    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    expect(response.parsed_body['response']['mode']).to eq('play_mode')
    expect(response.parsed_body['response']['ai_mode']).to eq('normal')
    expect(response.parsed_body['response']['turn']).to eq('white')
    avail = ActiveSupport::JSON.decode(response.parsed_body['response']['available_moves'])
    expect(avail['5']).to eq([6,7])
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])

    selected = '["5","7"]'
    board_state['white'].delete('5')
    board_state['white']['7'] = 'pawn'    
    response = make_play_update ActiveSupport::JSON.encode(board_state), selected, "white", g1.id
    expect(response.parsed_body['response']['turn']).to eq('white')
    # board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
  end

  it "can update in choose mode for both players, switch to play, and play" do
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']

    # join the game for u1 again, now as player2
    sign_in :user, u1
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id, "join" => game_id}, "version" => 1}
    response = post :create, data

    g1 = StarchessGame.find(game_id)
    expect(g1.mode).to eq('choose_mode')
    data = {"starchess_game" => {"board_state" => 
      '{"white" : {"5":"pawn", "12":"pawn", "18":"pawn", "23":"pawn", "29":"pawn"}, 
      "black" : {"9":"pawn", "15":"pawn", "20":"pawn", "26":"pawn", "33":"pawn"}}', 
      "turn" => "white",
      "chosen_piece" => '{"piece_type" : "rook", "space_id" : 4}'}, 
      "id" => g1.id, "version" => 1}
    response = patch :update, data

    expect(response.parsed_body['response']['turn']).to eq('black')
    expect(response.parsed_body['response']['mode']).to eq('choose_mode')
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    expect(board_state['white']['4']).to eq('rook')
    expect(response.parsed_body['response']['available_moves']).to eq("[10,16,21,27,34]")

    response=make_choose_update response, "black", "rook", 10, g1.id
    response=make_choose_update response, "white", "bishop", 11, g1.id
    response=make_choose_update response, "black", "bishop", 21, g1.id
    response=make_choose_update response, "white", "knight", 17, g1.id
    response=make_choose_update response, "black", "knight", 16, g1.id
    cloned_response = response.deep_dup
    error_response = make_choose_update response, "white", "king", 21, g1.id
    expect(error_response.status).to eq(400)
    response=make_choose_update cloned_response, "white", "king", 22, g1.id
    response=make_choose_update response, "black", "queen", 27, g1.id
    response=make_choose_update response, "white", "queen", 28, g1.id
    response=make_choose_update response, "black", "king", 34, g1.id

    expect(response.parsed_body['response']['mode']).to eq('play_mode')
    expect(response.parsed_body['response']['turn']).to eq('white')
    avail = ActiveSupport::JSON.decode(response.parsed_body['response']['available_moves'])
    expect(avail['5']).to eq([6,7])
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    selected = '["5","9"]' # this is a fake move
    board_state['white'].delete('5')
    board_state['white']['7'] = 'pawn'    
    
    error_response = make_play_update ActiveSupport::JSON.encode(board_state), selected, "white", g1.id
    expect(error_response.status).to eq(400)

    selected = '["5","7"]'
    response = make_play_update ActiveSupport::JSON.encode(board_state), selected, "white", g1.id
    expect(response.parsed_body['response']['turn']).to eq('black')
  end

  it "can report a checkmate and set winner id" do
    board_state = {:white => {4 => :king, 23 => :pawn, 6 =>:pawn}, 
      :black => {7 => :rook, 12 => :queen}}
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']

    # join the game for u1 again, now as player2
    sign_in :user, u1
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id, "join" => game_id}, "version" => 1}
    response = post :create, data

    logic = StarChess::Game.new :play_mode, board_state, nil
    info = logic.get_game_info :black
    g1 = StarchessGame.find(game_id)
    g1.mode = 'play_mode'
    g1.board_state = ActiveSupport::JSON.encode(board_state)
    g1.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
    g1.turn = "black"
    g1.save!

    # do the checkmate move
    selected = '["7","6"]'
    board_state = {:white => {4 => :king, 23 => :pawn}, 
      :black => {6 => :rook, 12 => :queen}}
    response = make_play_update ActiveSupport::JSON.encode(board_state), selected, "black", g1.id
    expect(response.parsed_body['response']["extra_state"]["special_state"]).to eq("checkmate")
    expect(response.parsed_body['response']['winner_id']).to eq(u1.id)
    expect(response.parsed_body['response']['extra_state']['saved_selected_move']).not_to be_nil
    g1 = StarchessGame.find(game_id)
    expect(g1.winner_id).to eq(u1.id)

  end

  it "can do pawn promotion thru api" do
    board_state = {:white => {4 => :king, 23 => :pawn, 6 =>:pawn, 9 => :pawn}, 
      :black => {7 => :rook, 12 => :queen}}
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']

    # join the game for u1 again, now as player2
    sign_in :user, u1
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u1.id, "join" => game_id}, "version" => 1}
    response = post :create, data

    logic = StarChess::Game.new :play_mode, board_state, nil
    info = logic.get_game_info :white
    g1 = StarchessGame.find(game_id)
    g1.mode = 'play_mode'
    g1.board_state = ActiveSupport::JSON.encode(board_state)
    g1.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
    g1.turn = "white"
    g1.save!

    # do the pawn promotion move
    selected = '["9","10"]'
    board_state = {:white => {4 => :king, 23 => :pawn, 6 => :pawn, 10 => :pawn}, 
      :black => {7 => :rook, 12 => :queen}}
    chosen_piece = ActiveSupport::JSON.encode({"space_id" => 10, "piece_type" => "queen"})
    data = {"starchess_game" => {"board_state" => ActiveSupport::JSON.encode(board_state),
        "turn" => "white",
        "selected_move" => selected, "chosen_piece" => chosen_piece},
        "id" => g1.id, "version" => 1}
    response = patch :update, data
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    expect(board_state["white"]["10"]).to eq("queen")
  end

end
