require "spec_helper"
require "starchess/board"
require "starchess/piece"

describe "StarChess Pawns" do 
  it "should know starting pawn moves" do
    board_state = {:white => {5 => :pawn, 12 => :pawn}, 
      :black => {9 => :pawn, 15 => :pawn}}
    b = StarChess::Board.new board_state

    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([6,7])
    moves = b.pieces[:white][1].get_available_moves
    expect(moves).to eq([13,14])
    moves = b.pieces[:black][1].get_available_moves
    expect(moves).to eq([14,13])
  end

  it "should know nonstarting pawn moves" do 
    board_state = {:white => {13 => :pawn}, :black => {32 => :pawn}}
    b = StarChess::Board.new board_state
    moves = b.pieces[:black][0].get_available_moves
    expect(moves).to eq([31])
    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([14])
  end

  it "should know blocked pawn moves" do
    board_state = {:white => {24 => :pawn, 14 => :pawn}, :black => {26 => :pawn, 15 => :pawn}}
    b = StarChess::Board.new board_state
    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([25])
    moves = b.pieces[:white][1].get_available_moves
    expect(moves).to eq([])
    moves = b.pieces[:black][0].get_available_moves
    expect(moves).to eq([25])
    moves = b.pieces[:black][1].get_available_moves
    expect(moves).to eq([])
  end

  it "should know pawn take moves" do
    board_state = {:white => {18 => :pawn}, :black => {13 => :pawn}}
    b = StarChess::Board.new board_state
    moves = b.pieces[:white][0].get_available_moves
    expect(moves).to eq([19,20,13])
    moves = b.pieces[:black][0].get_available_moves
    expect(moves).to eq([12,18])
  end
end