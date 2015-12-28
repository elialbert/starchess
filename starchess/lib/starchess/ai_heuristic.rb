module StarChess
  class AIHeuristic
    attr_accessor :game
    def initialize(game)
      @game = game
    end

    def run(color, available_moves, board_state)
      opp_color = (color == :white) ? :black : :white
      original_spaces = @game.board.spaces.deep_dup
      # reversed_opponents_avail = get_reversed_opponents_available_moves opp_color, board_state
      # puts "reversed opp avail is #{reversed_opponents_avail}"
      available_moves_score_count = Hash.new { |hash, key| hash[key] = 0 }
      available_moves.each do |from, to_list|
        to_list.each do |to|
          move_key = "#{from},#{to}"
          if @game.game_variant_type == 'starcraft'
            if board_state[color][to] && StarChess::PROMOTION_PIECE_POINTS.keys().include?(board_state[color][to].to_sym)
              available_moves_score_count[move_key] += StarChess::PROMOTION_PIECE_POINTS[board_state[color][to].to_sym] / 2
              puts "promotion score increase: #{available_moves_score_count[move_key]}"
            elsif from == to
              available_moves_score_count[move_key] += 2
            end
          end
          piece_type = board_state[color][from]
          # will the move take a piece? if so add a score value
          available_moves_score_count[move_key] += StarChess::PIECE_POINTS[board_state[opp_color][to]]
          # then check if a given move is a threatened square
          # then check if a given move creates a threat in either direction
          available_moves_score_count[move_key] += check_move_threat color, opp_color, board_state, original_spaces, piece_type, from, to
          # go back to original board state hopefully
          @game.board.reconstruct board_state
        end
      end
      available_moves_score_count
    end

    def check_move_threat color, opp_color, board_state, original_spaces, piece_type, from, to
      total_threat_score = 0
      @game.board.change_board_state(board_state.deep_dup, original_spaces, color, opp_color, from, to)
      new_available_moves_list = @game.board.get_available_moves(color, true)[to]
      new_available_moves_list.each do |potential_next_move|
        total_threat_score += StarChess::PIECE_POINTS[board_state[opp_color][potential_next_move]] / 2
      end

      opp_avail = get_reversed_opponents_available_moves opp_color, board_state
      if opp_avail[to]
        total_threat_score -= StarChess::PIECE_POINTS[piece_type] # - StarChess::PIECE_POINTS[opp_avail[to]])
      end
      total_threat_score
    end

    def get_reversed_opponents_available_moves opp_color, board_state
      reversed_avail = {}
      opponents_avail = @game.board.get_available_moves(
        opp_color.to_sym, true)
      opponents_avail.each do |from, to_list|
        to_list.each do |to|
          reversed_avail[to] = board_state[opp_color.to_sym][from]
        end
      end
      reversed_avail
    end
  end
end
