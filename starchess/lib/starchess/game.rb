require 'starchess/board'
require 'starchess/piece_defs'

module StarChess
  class Game
    attr_reader :board, :board_state, :chosen_pieces
    attr_accessor :mode, :game_variant_type
    def initialize(game_mode, board_state = nil, chosen_pieces = nil, game_variant_type=nil)
      puts "initializing with game variant type #{game_variant_type}"
      @board = (game_variant_type == "starcraft") ? StarChess::StarcraftBoard.new(board_state) : StarChess::Board.new(board_state)
      @mode = game_mode
      @chosen_pieces = chosen_pieces || {:white => [], :black => []}.with_indifferent_access
    end

    def get_game_info color
      info = {:state => @board.get_state, :mode => @mode, :special_state => @board.special_state}
      if @mode == :play_mode
        info[:available_moves] = @board.get_available_moves color
        info[:special_state] = @board.special_state
      else
        info[:available_moves] = self.get_choose_moves color, info[:state]
      end
      info
    end

    def check_move_validity(selected_move, available_moves)
      return true if @mode.to_sym == :choose_mode or selected_move[0] == 'just_switched_modes'
      return (available_moves[selected_move[0].to_s] || []).include? selected_move[1].to_i 
    end

    def get_choose_moves color, board_state
      return StarChess::CHOSEN_SPACES[color] - board_state[color].keys
    end

    def do_pawn_promotion color, chosen_piece
      if space_id = @board.check_pawn_promotion(color)
        if chosen_piece['space_id'] == space_id
          @board.do_pawn_promotion color, space_id, chosen_piece['piece_type']
        end
      end
    end

    def add_piece color, piece_type, space_id
      raise StarChess::PieceError, "#{piece_type} is not allowed" unless 
        StarChess::CHOSEN_PIECE_TYPES.include? piece_type
      raise StarChess::PieceError, "#{piece_type} has already been chosen" if 
        @chosen_pieces[color].include? piece_type
      @board.add_chosen_piece color, piece_type, space_id
      @chosen_pieces[color] << piece_type
    end


  end

  class PieceError < RuntimeError
  end
  class TurnError < RuntimeError
  end

end