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
        result[move] = [move]
      end
      result
    end
    
    def get_available_moves(color, recursed = nil)
      result = super 
      result.merge get_pawn_creation_moves color
    end 

    def get_promotion piece_type
      return StarChess::STARCRAFT_PROMOTIONS[piece_type]
    end

    def check_move_validity selected_move, available_moves, old_board_state, color
      # check pawn creation
      new_state = self.get_state  
      return new_state[color][selected_move[1]] == :pawn if selected_move[0] == selected_move[1]
      
      # check if moving piece was pawn and taken piece was own color
      # if so, check if promotion was correct
      moving_piece_type = old_board_state[color][selected_move[0]]
      return true unless moving_piece_type.to_sym == :pawn
      taken = old_board_state[color][selected_move[1]]
      return true unless taken
      new_piece = new_state[color][selected_move[1]]
      return get_promotion(taken) == new_piece
    end

    def count_piece_type piece_type, color
      self.get_state[color].values().count piece_type
    end
  end
end
