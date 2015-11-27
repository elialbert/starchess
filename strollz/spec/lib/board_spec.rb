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
end