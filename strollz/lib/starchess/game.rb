require 'starchess/board'
require 'starchess/piece_defs'

module StarChess
  class Game
    attr_reader :board, :game_state, :chosen_pieces
    def initialize(game_mode, board_state = nil, chosen_pieces = nil)
      @board = StarChess::Board.new board_state
      @mode = game_mode
      @chosen_pieces ||= {:white => [], :black => []}
    end

    def get_game_info color
      info = {:state => @board.get_state}
      if @mode == :play_mode
        info[:available_moves] = @board.get_available_moves color
      end
      info
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

end