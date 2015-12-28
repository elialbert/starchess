require 'starchess/ai/ai_heuristic'
require 'starchess/ai/ai_recursive'

module StarChess
  # basic move looper / ai chooser
  class AIRunner
    attr_accessor :game
    def initialize(game, color, ai_type)
      @game = game
      opp_color = (color == :white) ? :black : :white
      original_spaces = @game.board.spaces.deep_dup
      ai_class = case ai_type
                 when 'heuristic'
                   AIHeuristic
                 when 'recursive'
                   AIRecursive
                 end
      @brain = ai_class.new(game, color, opp_color, original_spaces)
    end

    def run(available_moves, board_state)
      # puts "reversed opp avail is #{reversed_opponents_avail}"
      scores = Hash.new { |hash, key| hash[key] = 0 }
      available_moves.each do |from, to_list|
        to_list.each do |to|
          scores = @brain.run(from, to, board_state, scores)
        end
      end
      puts "final scores are"
      puts scores
      scores
    end
  end
end
