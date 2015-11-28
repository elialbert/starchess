require "spec_helper"

describe StarchessGamesController, :type => :controller do  
  u1,u2=nil

  def make_choose_update response, turn, piece_type, space_id, game_id
    board_state = response.parsed_body['response']['board_state']
    data = {"starchess_game" => {"board_state" => board_state,
      "turn" => turn,
      "chosen_piece" => '{"piece_type": "'+piece_type.to_s+'", "space_id": '+space_id.to_s+'}'},
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

  end

  it "can update in choose mode for both players, switch to play, and play" do
    data = {"starchess_game" => {"player1_id" => u1.id, "player2_id" => u2.id}, "version" => 1}
    response = post :create, data
    game_id = response.parsed_body['response']['id']
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
    expect {
      make_choose_update response, "white", "king", 21, g1.id
      }.to raise_error(StarChess::SpaceError)
    response=make_choose_update cloned_response, "white", "king", 22, g1.id
    response=make_choose_update response, "black", "queen", 27, g1.id
    response=make_choose_update response, "white", "queen", 28, g1.id
    response=make_choose_update response, "black", "king", 34, g1.id

    expect(response.parsed_body['response']['mode']).to eq('play_mode')
    puts(response.parsed_body['response'])
    expect(response.parsed_body['response']['turn']).to eq('white')
    avail = ActiveSupport::JSON.decode(response.parsed_body['response']['available_moves'])
    expect(avail['5']).to eq([6,7])
  end

end