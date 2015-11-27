require "spec_helper"
require "starchess/board"

describe "StarChess Board" do 
  b=nil
  before do
    b = StarChess::Board.new
  end
  it "should initialize spaces" do
    expect(b.spaces.length).to eq(37)
    expect(b.spaces[1].northeast).to eq(b.spaces[3])
    expect(b.spaces[3].southeast).to eq(b.spaces[7])
    expect(b.spaces[24].north).to eq(b.spaces[25])
    expect(b.spaces[37].south).to eq(nil)
  end

  it "should have pawns for both colors" do
    expect(b.pieces[:white].length).to be > 0
    expect(b.pieces[:black].length).to be > 0
    expect(b.pieces[:white][0].space.id).to eq(5)
  end

  it "should allow players to choose starting pieces" do
    b.add_chosen_piece :white, :king, 4
    expect(b.pieces[:white][5].space.id).to eq(4)
    b.add_chosen_piece :black, :queen, 34
    expect(b.pieces[:black][5].piece_type).to eq(:queen)
    expect(b.pieces[:black][5].space.id).to eq(34)
    expect(b.spaces[34].piece.piece_type).to eq(:queen)
  end

  it "should not allow choosing a piece on a square with a piece" do
    b.add_chosen_piece :white, :king, 4
    expect {
      b.add_chosen_piece :white, :queen, 4
    }.to raise_error(StarChess::SpaceError)
  end

  it "should not allow choosing a piece on a nonchoosable space" do
    expect {
      b.add_chosen_piece :white, :queen, 19
    }.to raise_error(StarChess::SpaceError)
  end


end