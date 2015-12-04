require "spec_helper"
require "starchess/starcraft_board"

describe "StarCraftChess Board" do 
  b=nil
  before do
    b = StarChess::StarcraftBoard.new
  end
  it "should initialize spaces and kings" do
    expect(b.spaces.length).to eq(37)
    expect(b.pieces[:white].length).to eq(1)
  end 
end