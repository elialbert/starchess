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

  def do_game(mode, board_state)
    g = StarChess::Game.new :choose_mode, board_state=board_state, chosen_pieces=nil
    return g.get_board_state
  end

  # simulate db interaction that will normally drive this
  def do_choose_game(mode, board_state, chosen_pieces, new_selection)
    g = StarChess::Game.new :choose_mode, board_state=board_state, chosen_pieces=chosen_pieces
    g.add_piece new_selection[:color], new_selection[:piece_type], new_selection[:space_id]
    return g.chosen_pieces, g.get_board_state
  end

  it "should be able to play a game" do
    board_state = do_game(:choose_mode, nil)
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
  end

end