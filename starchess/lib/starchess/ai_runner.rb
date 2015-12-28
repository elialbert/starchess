require 'starchess/ai_heuristic'

module StarChess
  # basic move looper / ai chooser
  class AIRunner
    attr_accessor :game
    def initialize(game)
      @game = game
      @brain = AIHeuristic.new(game)
    end

    def run(color, available_moves, board_state)
      @brain.color = color
      @brain.opp_color = (color == :white) ? :black : :white
      @brain.original_spaces = @game.board.spaces.deep_dup
      # puts "reversed opp avail is #{reversed_opponents_avail}"
      scores = Hash.new { |hash, key| hash[key] = 0 }
      available_moves.each do |from, to_list|
        to_list.each do |to|
          scores = @brain.run(from, to, board_state, scores)
        end
      end
      scores
    end
  end
end
