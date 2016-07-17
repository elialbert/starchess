require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'
require 'starchess/board'
require 'starchess/starcraft_piece'

module StarChess
  class StarcraftBoard < StarChess::Board
    def initialize(board_state = nil, mode = :play_mode, random_pieces = false)
      @piece_class = StarChess::StarcraftPiece
      @spaces = {}.with_indifferent_access # int ID to Space instance
      @pieces = {:white => [], :black => []}.with_indifferent_access
      @special_state = nil
      self.construct_spaces
      board_state ? self.reconstruct(board_state) : self.setup_starcraft_board
    end

    def setup_starcraft_board
      StarChess::STARCRAFT_SETUP.each do |color, piece_map|
        piece_map.each do |space_id, piece_type|
          space = @spaces[space_id]
          piece = @piece_class.new self, piece_type, color, space
          space.piece = piece
          @pieces[color] << piece
        end
      end
    end

    def get_pawn_creation_moves color
      king_piece = self.get_king_piece color
      king_moves = king_piece.get_king_moves nil, true
      result = {}
      king_moves.each do |move|
        result[move] = [move] if @spaces[move].piece.nil?
      end
      result
    end

    def get_available_moves(color, recursed = nil)
      result = super
      if recursed.nil? && ![:check,:checkmate].include?(@special_state)
        result = result.merge get_pawn_creation_moves color
      end
      return result
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
      if old_board_state[color] and old_board_state[color].keys()[0].class == String
        selected_move = [selected_move[0].to_s, selected_move[1].to_s]
      end
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
