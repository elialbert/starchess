module StarChess
  # one possible ai
  class AIHeuristic
    attr_accessor :game, :color, :opp_color, :original_spaces
    def initialize(game, color, opp_color, original_spaces)
      @game, @color, @opp_color, @original_spaces = game, color, opp_color,
        original_spaces
    end

    def run(from, to, board_state, scores)
      scores ||= Hash.new { |hash, key| hash[key] = 0 }
      move_key = "#{from},#{to}"
      if @game.game_variant_type == 'starcraft'
        scores = check_pawn_promotion(board_state, from, to)
      end
      piece_type = board_state[color][from]
      # will the move take a piece? if so add a score value
      scores[move_key] += StarChess::PIECE_POINTS[board_state[opp_color][to]]
      # then check if a given move is a threatened square
      # then check if a given move creates a threat in either direction
      scores[move_key] += check_move_threat(board_state, piece_type, from, to)
      # go back to original board state hopefully
      @game.board.reconstruct board_state
      scores
    end

    def check_pawn_promotion(board_state, from, to)
      if board_state[@color][to] &&
         StarChess::PROMOTION_PIECE_POINTS.keys.include?(
           board_state[@color][to].to_sym)
        scores[move_key] += StarChess::PROMOTION_PIECE_POINTS[
          board_state[@color][to].to_sym] / 2
      elsif from == to
        scores[move_key] += 2
      end
    end

    def check_move_threat(board_state, piece_type, from, to)
      total_threat_score = 0
      @game.board.change_board_state(board_state.deep_dup,
                                     @original_spaces,
                                     @color, @opp_color, from, to)
      new_available_moves = @game.board.get_available_moves(@color, true)[to]
      new_available_moves.each do |potential_next_move|
        total_threat_score += StarChess::PIECE_POINTS[
          board_state[@opp_color][potential_next_move]] / 2
      end

      opp_avail = get_reversed_opponents_available_moves(board_state)
      total_threat_score -= StarChess::PIECE_POINTS[piece_type] if opp_avail[to]
      total_threat_score
    end

    def get_reversed_opponents_available_moves(board_state)
      reversed_avail = {}
      opponents_avail = @game.board.get_available_moves(
        @opp_color.to_sym, true)
      opponents_avail.each do |from, to_list|
        to_list.each do |to|
          reversed_avail[to] = board_state[@opp_color.to_sym][from]
        end
      end
      reversed_avail
    end
  end
end
