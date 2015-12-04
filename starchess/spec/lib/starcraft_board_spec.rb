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

  it "should get available starting pawn moves" do
    result = b.get_available_moves :white
    expect(result[4]).to eq([5,11])
    result = b.get_available_moves :black
    expect(result[27]).to eq(27)
  end

  it "it should initialize a board midgame and understand pawn promotion" do
    board_state = {:white => {4 => :king, 5 => :pawn, 11 => :pawn}, :black => {34 => :king, 27 => :pawn}}

    b = StarChess::StarcraftBoard.new board_state
    result = b.get_available_moves :white
    expect(result[11]).to eq([12, 5])
    expect(result[4]).to eq([])
  end
end