require "spec_helper"
require "starchess/ai/ai"

describe "StarChess AI" do
  ai = nil
  before do
    ai = StarChess::AI.new 'single_mode'
  end

  it "should be helpful" do
      board_state = '{"white":{"4":"king","5":"pawn","11":"queen","12":"pawn","17":"rook","19":"pawn","22":"knight","23":"pawn","28":"bishop","29":"pawn"},"black":{"9":"pawn","10":"knight","15":"pawn","16":"bishop","20":"pawn","21":"king","26":"pawn","27":"rook","33":"pawn","34":"queen"}}'
      board_state = ActiveSupport::JSON.decode(board_state)
      ai.game = StarChess::Game.new :play_mode, board_state, nil
      info = ai.game.get_game_info :black
      ai_result = ai.run_ai :black, info[:available_moves], info[:state], "heuristic"
      expect(ai_result[10].include? 14).not_to be true
  end
end
