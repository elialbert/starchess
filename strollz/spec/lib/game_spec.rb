require "spec_helper"
require "starchess/game"

describe "StarChess Game" do 
  g=nil
  before do
    g = StarChess::Game.new :choose_mode
  end

  it "should initialize board" do
    expect(g.board.spaces.length).to eq(37)
  end 

  it "should allow choosing pieces" do
    g.add_piece :white, :queen, 17
    new_piece = g.board.spaces[17].piece
    expect(new_piece.color).to eq(:white)
    expect(new_piece.piece_type).to eq(:queen)
  end

  it "should prevent made up pieces and repeat pieces" do
    g.add_piece :black, :rook, 27
    expect {
      g.add_piece :black, :foo, 21
    }.to raise_error StarChess::PieceError
    expect {
      g.add_piece :black, :rook, 27
    }.to raise_error StarChess::PieceError
    g.add_piece :black, :king, 21
    expect(g.board.spaces[21].piece.piece_type).to eq(:king)
  end

  def do_game(mode, board_state, color) # color is who just moved
    g = StarChess::Game.new mode, board_state, nil
    opposite_color = (color == :black) ? :white : :black
    return g.get_game_info opposite_color
  end

  # simulate db interaction that will normally drive this
  def do_choose_game(mode, board_state, chosen_pieces, new_selection)
    g = StarChess::Game.new :choose_mode, board_state, chosen_pieces
    g.add_piece new_selection[:color], new_selection[:piece_type], new_selection[:space_id]
    return g.chosen_pieces, g.get_game_info(new_selection[:color])[:state]
  end

  it "should be able to play a game" do
    board_state = do_game(:choose_mode, nil, nil)[:state]
    expect(board_state[:white].length).to eq(5)
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, nil, 
                                  {:color => :white, :piece_type => :rook, :space_id => 11})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :black, :piece_type => :queen, :space_id => 34})
    expect(chosen_pieces[:black][0]).to eq(:queen)
    expect(board_state[:white].length).to eq(6)

    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :white, :piece_type => :bishop, :space_id => 4})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :black, :piece_type => :king, :space_id => 27})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :white, :piece_type => :knight, :space_id => 22})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :black, :piece_type => :bishop, :space_id => 21})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :white, :piece_type => :queen, :space_id => 17})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :black, :piece_type => :rook, :space_id => 10})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :white, :piece_type => :king, :space_id => 28})
    chosen_pieces, board_state = do_choose_game(:choose_mode, board_state, chosen_pieces, 
                                  {:color => :black, :piece_type => :knight, :space_id => 16})

    expect(board_state[:white].length).to eq(10)
    expect(board_state[:black].length).to eq(10)

    expect(board_state[:white][28]).to eq(:king)

    info = do_game(:play_mode, board_state, :black)
    expect(info[:state][:white][5]).to eq(:pawn)
    expect(info[:available_moves][5]).to eq([6,7])

    board_state = info[:state]
    board_state[:white].delete(5)
    board_state[:white][7] = :pawn
    info = do_game(:play_mode, board_state, :white) # white moves 
    # and now we have black's avail in info
    expect(info[:state][:white][7]).to eq(:pawn)
    expect(info[:available_moves][9]).to eq([8])

    board_state = info[:state]
    board_state[:black].delete(20)
    board_state[:black][19] = :pawn
    info = do_game(:play_mode, board_state, :black) # black moves
    expect(info[:available_moves][18]).to eq([])    

    board_state = info[:state]
    board_state[:white].delete(12)
    board_state[:white][13] = :pawn
    info = do_game(:play_mode, board_state, :white) # white moves 

    board_state = info[:state]
    board_state[:black].delete(19)
    board_state[:white].delete(13)
    board_state[:black][13] = :pawn
    info = do_game(:play_mode, board_state, :black) # black moves
    expect(info[:available_moves]).not_to include(13)
  end

  it "should calculate check moves correctly" do
    board_state = '{"white":{"4":"bishop","5":"pawn","17":"rook","19":"pawn","28":"queen","29":"king","31":"pawn"},"black":{"9":"pawn","10":"bishop","20":"rook","23":"pawn","25":"pawn","27":"queen","30":"knight","33":"pawn","34":"king"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    info = do_game(:play_mode, board_state, :black)
    expect(info[:available_moves][29]).to eq([30,23,22])
  end

  it "should not miss random checks" do
    board_state = '{"white":{"4":"bishop","8":"queen","17":"rook","30":"king","31":"pawn"},"black":{"5":"queen","9":"pawn","10":"bishop","18":"pawn","20":"rook","33":"pawn","34":"king"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    info = do_game(:play_mode, board_state, :white)
    expect(info[:special_state]).to eq(:check)
  end

  it "should not allow to move a piece putting your king in check" do
    board_state = '{"white":{"4":"bishop","8":"queen","17":"rook","30":"king","32":"pawn"},"black":{"5":"queen","9":"pawn","18":"pawn","20":"rook","21":"bishop","33":"pawn","34":"king"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    info = do_game(:play_mode, board_state, :white)
    expect(info[:available_moves][21]).not_to include(32)
  end

  it "should understand a stalemate" do
    board_state = '{"white":{"25":"king","32":"pawn"},"black":{"9":"pawn","12":"queen","15":"king","20":"rook","33":"pawn"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    info = do_game(:play_mode, board_state, :black)
    expect(info[:special_state]).to eq(:stalemate)
  end

  it "should allow to take out of check sandwich" do
    board_state = '{"white":{"5":"queen","6":"pawn","7":"knight","11":"king","20":"bishop","27":"rook","30":"pawn"},"black":{"8":"pawn","9":"king","13":"bishop","14":"pawn","15":"queen","32":"pawn"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    info = do_game(:play_mode, board_state, :white)
    expect(info[:available_moves][15]).to eq([20])
  end

  it "should handle checkmate" do
    board_state = {:white => {4 => :king, 23 => :pawn}, 
      :black => {6 => :rook, 12 => :queen}}
    info = do_game(:play_mode, board_state, :black)
    puts info
    expect(info[:special_state]).to eq(:checkmate)
  end
end