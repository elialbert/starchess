require "spec_helper"
require "starchess/board"

describe "StarChess Board" do 
  it "should initialize spaces" do
    b = StarChess::Board.new
    expect(b.spaces.length).to eq(37)
    expect(b.spaces[1].northeast).to eq(b.spaces[3])
    expect(b.spaces[3].southeast).to eq(b.spaces[7])
    expect(b.spaces[24].north).to eq(b.spaces[25])
    expect(b.spaces[37].south).to eq(nil)
  end
end