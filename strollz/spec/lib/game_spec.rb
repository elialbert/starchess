require "spec_helper"
require "starchess/game"

describe "StarChess Game" do 
  g=nil
  before do
    g = StarChess::Game.new
  end

  it "should initialize board" do
    expect(g.board.spaces.length).to eq(37)
  end 

end