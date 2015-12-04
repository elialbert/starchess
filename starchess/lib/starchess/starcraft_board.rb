require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'
require 'starchess/board'

module StarChess
  class StarcraftBoard < StarChess::Board
    def initialize(board_state = nil)
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

  end
end
