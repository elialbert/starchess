require "spec_helper"
require "starchess/board"

describe "StarChess Bishops and Rooks" do 
  it "should move rooks north and south" do
    board_state = {:white => {17 => :rook}, 
      :black => {20 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([18,19,20])

    board_state = {:black => {20 => :rook}, 
      :white => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:black][0].get_available_moves
    expect(moves).to eq([21,19,18,17])
  end

  it "should have rooks be blocked by own and take other color" do
    board_state = {:white => {19 => :rook, 21 => :king}, 
      :black => {17 => :queen}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([20,18,17])
  end

  it "should moves bishops diagonal" do
    board_state = {:white => {8 => :bishop}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([3,1,14,19,24,30,15,21,27,34])
  end

  it "should have bishops be blocked by own and take other color" do
    board_state = {:white => {19 => :bishop, 32 => :king}, 
      :black => {8 => :queen, 6 => :pawn, 24 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([14,8,13,6,24,25])
  end
end