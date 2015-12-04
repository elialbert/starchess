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
    expect(result[4]).to eq([4])
    result = b.get_available_moves :black
    expect(result[21]).to eq([21])
  end

  it "it should initialize a board midgame and understand pawn promotion" do
    board_state = {:white => {4 => :king, 5 => :pawn, 11 => :pawn}, :black => {34 => :king, 27 => :pawn}}

    b = StarChess::StarcraftBoard.new board_state
    result = b.get_available_moves :white
    expect(result[11]).to eq([12, 5])
    expect(result[4]).to eq([])
  end
 
  it "should allow a pawn to take or promote depending on color" do
    board_state = {:white => {4 => :king, 24 => :pawn, 31 => :pawn}, 
      :black => {34 => :king, 19 => :pawn}}

    b = StarChess::StarcraftBoard.new board_state
    result = b.get_available_moves :white
    expect(result[24]).to eq([25, 19, 31])
  end

  it "should only allow a pawn to promote when there are not too many of that piece type" do
    board_state = {:white => {4 => :king, 24 => :pawn, 31 => :pawn, 1 => :knight, 2 => :knight}, 
      :black => {34 => :king, 19 => :pawn}}

    b = StarChess::StarcraftBoard.new board_state
    result = b.get_available_moves :white
    expect(result[24]).to eq([25, 19])
  end

  it "should assert move validity for pawn creation" do
    original_board_state = {:white => {4 => :king, 31 => :pawn, 19 => :pawn, 24 => :pawn}, 
      :black => {34 => :king, 27 => :pawn}}
    b1 = StarChess::StarcraftBoard.new original_board_state
    available_moves = b1.get_available_moves :black

    expect(available_moves[33]).to eq([33])
    selected_move = [33,33]
    board_state = {:white => {4 => :king, 31 => :pawn, 19 => :pawn, 24 => :pawn}, 
      :black => {34 => :king, 27 => :pawn, 33 => :pawn}}
    b2 = StarChess::StarcraftBoard.new board_state
    expect(b2.check_move_validity(selected_move, 
            available_moves, original_board_state, :black)).to be true

    board_state = {:white => {4 => :king, 31 => :pawn, 19 => :pawn, 24 => :pawn}, 
      :black => {34 => :king, 27 => :pawn, 33 => :rook}}
    b3 = StarChess::StarcraftBoard.new board_state
    expect(b3.check_move_validity(selected_move, 
            available_moves, original_board_state, :black)).to be false
  end

  it "should assert move validity for pawn promotion" do
    original_board_state = {:white => {4 => :king, 31 => :pawn, 19 => :pawn, 24 => :pawn}, 
      :black => {34 => :king, 27 => :pawn}}
    b1 = StarChess::StarcraftBoard.new original_board_state
    available_moves = b1.get_available_moves :white

    board_state = {:white => {4 => :king, 31 => :pawn, 19 => :knight}, 
      :black => {34 => :king, 27 => :pawn}}
    selected_move = [24,19]
    b2 = StarChess::StarcraftBoard.new board_state
    expect(b2.check_move_validity(selected_move, 
            available_moves, original_board_state, :white)).to be true


    board_state = {:white => {4 => :king, 31 => :pawn, 19 => :queen}, 
      :black => {34 => :king, 27 => :pawn}}
    selected_move = [24,19]
    b3 = StarChess::StarcraftBoard.new board_state
    expect(b3.check_move_validity(selected_move, 
            available_moves, original_board_state, :white)).to be false
  end

  it "should still be able to compute when in check" do
    board_state = '{"white":{"19":"knight","6":"pawn","7":"king","9":"queen","13":"pawn","14":"pawn","16":"pawn","17":"pawn"},"black":{"24":"pawn","27":"pawn","28":"pawn","33":"king","21":"bishop"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    b1 = StarChess::StarcraftBoard.new board_state
    available_moves = b1.get_available_moves :black
    expect(available_moves.keys().length).to eq(1)
  end

  it "should allow rooks a little more freedom" do 
    board_state = {:white => {4 => :king, 31 => :pawn, 19 => :pawn, 24 => :pawn}, 
      :black => {34 => :king, 27 => :pawn, 25 => :rook}}
    b1 = StarChess::StarcraftBoard.new board_state
    available_moves = b1.get_available_moves :black
    expect(available_moves[25]).to eq([26, 24, 20, 32])
  end

  it "should not allow pawn creation on a held square" do
    board_state = {:white => {4 => :king, }, 
      :black => {34 => :king, 24 => :pawn, 11 => :rook}}
    b1 = StarChess::StarcraftBoard.new board_state
    available_moves = b1.get_available_moves :white
    expect(available_moves[11]).to eq([])
  end
end