require "spec_helper"
require "starchess/board"

describe "StarChess Knights" do 
  it "should move all funny like and jump pieces" do
    board_state = {:white => {19 => :knight}, 
      :black => {20 => :pawn, 26 => :pawn, 1 => :pawn, 12 => :pawn, 17 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([27,16,9,3,2,5,11,22,29,35,36,33])
  end

  it "should be blocked by same color and take opponent" do
    board_state = {:white => {19 => :knight, 33 => :pawn}, 
      :black => {20 => :pawn, 26 => :pawn, 16 => :pawn, 35 => :pawn, 17 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([27,16,9,3,2,5,11,22,29,35,36])
  end
end