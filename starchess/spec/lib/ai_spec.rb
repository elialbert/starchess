require "spec_helper"
require "starchess/ai/ai"

describe "StarChess AI" do
  ai = nil
  before(:each) do
    ai = StarChess::AI.new 'single_mode'
  end

  it "should have a helperful heuristic" do
      board_state = '{"white":{"4":"king","5":"pawn","11":"queen","12":"pawn","17":"rook","19":"pawn","22":"knight","23":"pawn","28":"bishop","29":"pawn"},"black":{"9":"pawn","10":"knight","15":"pawn","16":"bishop","20":"pawn","21":"king","26":"pawn","27":"rook","33":"pawn","34":"queen"}}'
      board_state = ActiveSupport::JSON.decode(board_state)
      ai.game = StarChess::Game.new :play_mode, board_state, nil
      info = ai.game.get_game_info :black
      ai_result = ai.run_ai :black, info[:available_moves], info[:state], "heuristic"
      expect(ai_result[10].include? 14).not_to be true
  end

  it "recursion should run and also be helpful" do
      board_state = '{"white":{"4":"king","5":"pawn","11":"queen","12":"pawn","17":"rook","19":"pawn","22":"knight","23":"pawn","28":"bishop","29":"pawn"},"black":{"9":"pawn","10":"knight","15":"pawn","16":"bishop","20":"pawn","21":"king","26":"pawn","27":"rook","33":"pawn","34":"queen"}}'
      board_state = ActiveSupport::JSON.decode(board_state)
      ai.game = StarChess::Game.new :play_mode, board_state, nil
      info = ai.game.get_game_info :black
      ai_result = ai.run_ai :black, info[:available_moves], info[:state], "recursive"
      expect(ai_result[10].include? 14).not_to be true
  end

  it "shouldnt crash" do
    board_state = '{"white":{"11":"king","12":"bishop"},"black":{"20":"pawn","27":"pawn","33":"king"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    ai.game = StarChess::Game.new :play_mode, board_state, nil
    info = ai.game.get_game_info :black
    ai_result = ai.run_ai :black, info[:available_moves], info[:state], "recursive"
  end

  it "should move knight out of danger" do
    board_state = '{"white":{"11":"pawn","12":"rook","17":"king","18":"bishop"},"black":{"3":"knight","15":"pawn","16":"pawn","20":"pawn","21":"king","26":"pawn","27":"knight","32":"pawn"}}'
    board_state = ActiveSupport::JSON.decode(board_state)
    ai.game = StarChess::Game.new :play_mode, board_state, nil
    info = ai.game.get_game_info :black
    ai_result = ai.run_ai :black, info[:available_moves], info[:state], "recursive"
    puts ai_result
    expect(ai_result[3]).to eq([19])
  end
end
