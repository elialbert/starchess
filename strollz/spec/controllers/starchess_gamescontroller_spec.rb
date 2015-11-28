require "spec_helper"

describe StarchessGamesController, :type => :controller do  
  u1,u2=nil

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
    expect(response.parsed_body['response']['available_moves']).to eq("[10,16,21,27,34]")

  end

  it "can update in choose mode for both players" do
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u2.id}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']
    g1 = StarchessGame.find(game_id)
    expect(g1.mode).to eq('choose_mode')
    data = {"starchess_game" => {"board_state" => 
      '{"white" : {"5":"pawn", "12":"pawn", "18":"pawn", "23":"pawn", "29":"pawn"}, 
      "black" : {"9":"pawn", "15":"pawn", "20":"pawn", "26":"pawn", "33":"pawn"}}', 
      "turn" => "black",
      "chosen_piece" => '{"piece_type" : "rook", "space_id" : 10}'}, 
      "id" => g1.id, "version" => 1}
    response = patch :update, data

    expect(response.parsed_body['response']['turn']).to eq('white')
    expect(response.parsed_body['response']['mode']).to eq('choose_mode')
    board_state = ActiveSupport::JSON.decode(response.parsed_body['response']['board_state'])
    expect(board_state['black']['10']).to eq('rook')
    expect(response.parsed_body['response']['available_moves']).to eq("[4,11,17,22,28]")
  end

end