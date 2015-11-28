require "spec_helper"
require "starchess/board"

describe "StarChess Kings" do 
  it "should move 1 space all directions" do
    board_state = {:white => {19 => :king}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([20,14,13,18,24,25])

    board_state = {:white => {30 => :king}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([31,24,23,29,35])
  end

  it "should be able to take a dude and be blocked by own dudes" do
    board_state = {:white => {4 => :king, 5 => :pawn}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([11])

    board_state = {:white => {4 => :king, 5 => :pawn}, 
      :black => {11 => :rook}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([11])
  end

  it "should not be able to move into check" do
    board_state = {:white => {17 => :king, 18 => :pawn}, 
      :black => {15 => :rook}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([22,23])


    board_state = {:white => {17 => :king}, 
      :black => {15 => :rook, 18 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([18,22,23])

    board_state = {:white => {17 => :king}, 
      :black => {15 => :rook, 18 => :pawn, 24 => :bishop}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([22,23])
  end

  it "should be able to be put into check and have limited moves" do
    board_state = {:white => {17 => :king, 18 => :pawn}, 
      :black => {6 => :bishop}}
    b = StarChess::Board.new board_state
    moves = b.get_available_moves :white
    expect(moves[18]).to eq([])
    expect(moves[17]).to eq([11,23])


    board_state = {:white => {17 => :king}, 
      :black => {6 => :bishop, 24 => :pawn, 18 => :pawn}}
    b = StarChess::Board.new board_state
    moves = b.get_available_moves :white
    expect(moves[18]).to eq([])
    expect(moves[17]).to eq([11])
  end

  it "should be able to block check with other pieces" do
    board_state = {:white => {17 => :king, 36 => :bishop}, 
      :black => {6 => :bishop}}
    b = StarChess::Board.new board_state
    moves = b.get_available_moves :white
    expect(moves[17]).to eq([18,11,23])
    expect(moves[36]).to eq([12])
  end
end