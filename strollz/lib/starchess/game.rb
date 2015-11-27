require 'starchess/board'
require 'starchess/piece_defs'

module StarChess
  class Game
    attr_reader :board
    def initialize
      @board = StarChess::Board.new
      @chosen_pieces = {:white => [], :black => []}
    end

    def add_piece color, piece_type, space_id
      raise StarChess::PieceError unless 
        StarChess::CHOSEN_PIECE_TYPES.include? piece_type
      raise StarChess::PieceError if 
        @chosen_pieces[color].include? piece_type
      @board.add_chosen_piece color, piece_type, space_id
      @chosen_pieces[color] << piece_type
    end


  end

  class PieceError < RuntimeError
  end

end