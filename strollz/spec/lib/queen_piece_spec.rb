require "spec_helper"
require "starchess/board"

describe "StarChess Queens" do 
  it "should have lots of moves on empty board" do
    board_state = {:white => {19 => :queen}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([20,21,14,8,13,6,18,17,24,30,25,32])

    board_state = {:black => {37 => :queen}, 
      :white => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:black][0].get_available_moves
    expect(moves).to eq([36,32,26,21,16,10,35,30,23,17,11,4])
  end

  it "should have less moves when constrained by own color" do
    board_state = {:white => {4 => :queen, 6 => :pawn, 12 => :pawn, 17 => :pawn}, 
      :black => {}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves  
    expect(moves).to eq([5,11])
  end

  it "should be able to take pieces" do
    board_state = {:white => {4 => :queen}, 
      :black => {6 => :pawn, 23 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves  
    expect(moves).to eq([5, 6, 11, 17, 23])
  end
end