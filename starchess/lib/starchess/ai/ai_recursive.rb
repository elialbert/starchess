require 'starchess/ai/ai_heuristic'

module StarChess
  # recursive ai using heuristic version (a lot)
  class AIRecursive
    attr_accessor :game, :color, :opp_color, :original_spaces
    def initialize(game, color, opp_color, original_spaces)
      @game, @color, @opp_color, @original_spaces = game, color, opp_color,
        original_spaces
    end

    def run(from, to, board_state, scores)
      heuristic = AIHeuristic.new(@game, @color, @opp_color, @original_spaces)
      scores = heuristic.run(from, to, board_state, scores)
      scores["#{from},#{to}"] += run_inner(board_state, 0, from, to, 0)
      scores
    end

    # switch colors, recreate board, rerun heuristic,
    # apply score back for that move key
    def run_inner(board_state, incremental, from, to, depth)
      available_moves, board_state = switch(board_state, from, to)

      heuristic = AIHeuristic.new(@game, @color, @opp_color,
                                  @game.board.spaces.deep_dup)

      available_moves.each do |fromm, to_list|
        to_list.each do |too|
          scores = heuristic.run(fromm, too, board_state, nil)
          inc = adjust_score(scores, depth)
          incremental += inc
          if depth < 2
            run_inner(board_state, incremental, fromm, too, depth + 1)
          end
        end
      end
      incremental
    end

    def switch(board_state, from, to)
      @color, @opp_color = @opp_color, @color
      @game.board.change_board_state(
        board_state.deep_dup,
        @game.board.spaces.deep_dup,
        @color, @opp_color, from, to)
      return @game.board.get_available_moves(@opp_color.to_sym, false),
        @game.board.get_state
    end

    def adjust_score(scores, depth)
      return -1 * scores.values.max if depth.even?
      scores.values.max
    end
  end
end
