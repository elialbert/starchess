require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'
require 'starchess/board'
require 'starchess/starcraft_piece'

module StarChess
  class StarcraftBoard < StarChess::Board
    def initialize(board_state = nil)
      @piece_class = StarChess::StarcraftPiece
      @spaces = {}.with_indifferent_access # int ID to Space instance
      @pieces = {:white => [], :black => []}.with_indifferent_access
      @special_state = nil
      self.construct_spaces
      board_state ? self.reconstruct(board_state) : self.setup_starcraft_board
    end

    def setup_starcraft_board
      StarChess::STARCRAFT_SETUP.each do |color, space_id|
        space = @spaces[space_id]
        king = StarChess::Piece.new self, :king, color, space
        space.piece = king
        @pieces[color] << king
      end
    end

    def get_pawn_creation_moves color
      king_piece = self.get_king_piece color
      king_moves = king_piece.get_king_moves nil, true
      result = {}
      king_moves.each do |move|
        result[move] = move
      end
      result
    end
    
    def get_available_moves(color, recursed = nil)
      result = super 
      result.merge get_pawn_creation_moves color
    end 
  end
end
