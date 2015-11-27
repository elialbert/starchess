require "spec_helper"
require "starchess/board"

describe "StarChess Board" do 
  it "should initialize spaces" do
    b = StarChess::Board.new
    expect(b.spaces.length).to eq(37)
    expect(b.spaces[1].northeast).to eq(b.spaces[3])
  end
end