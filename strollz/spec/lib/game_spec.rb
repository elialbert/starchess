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

  it "should allow choosing pieces" do
    g.add_piece :white, :queen, 17
    new_piece = g.board.spaces[17].piece
    expect(new_piece.color).to eq(:white)
    expect(new_piece.piece_type).to eq(:queen)
  end

  it "should prevent made up pieces and repeat pieces" do
    g.add_piece :black, :rook, 27
    expect {
      g.add_piece :black, :foo, 21
    }.to raise_error StarChess::PieceError
    expect {
      g.add_piece :black, :rook, 27
    }.to raise_error StarChess::PieceError
    g.add_piece :black, :king, 21
    expect(g.board.spaces[21].piece.piece_type).to eq(:king)
  end

end