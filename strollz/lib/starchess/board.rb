require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'

module StarChess
  class Board
    attr_accessor :spaces, :pieces
    attr_reader :special_state
    def initialize(board_state = nil)
      @spaces = {}.with_indifferent_access # int ID to Space instance
      @pieces = {:white => [], :black => []}.with_indifferent_access
      @special_state = nil
      self.construct_spaces
      board_state ? self.reconstruct(board_state) : self.setup_pawns
    end

    def inspect
      s = "\n"
      @pieces.each do |color, color_pieces|
        s << "#{color.to_s}: \n"
        color_pieces.each do |piece|
          s << "#{piece.space.id.to_s}: #{piece.piece_type.to_s}\n" 
        end
      end
      s
    end

    def get_state
      state = {:white => {}, :black => {}}.with_indifferent_access
      @pieces.each do |color, pieces| 
        pieces.each do |piece|
          state[color][piece.space.id] = piece.piece_type
        end
      end
      state
    end

    def get_available_moves(color, recursed = nil)
      result = {}
      king = nil
      opposite_color = (color == :black) ? :white : :black
      # opp_extra = get_available_moves(
      #   opposite_color, true) if not recursed
      # opponents_flattened_avail = opp_extra.values.flatten if not recursed
      opponents_flattened_avail = get_available_moves(
        opposite_color, true).values.flatten if not recursed
      @pieces[color].each do |piece|
        # dict of space id => list of space ids
        if (piece.piece_type == :king)
          result[piece.space.id] = piece.get_king_moves(
                                          opponents_flattened_avail=opponents_flattened_avail,
                                          recursed)
          king = piece
        elsif (piece.piece_type == :pawn)
          result[piece.space.id] = piece.get_pawn_moves recursed
        else
          result[piece.space.id] = piece.get_available_moves 
        end          
      end
      # find other color moves
      # if king's square is in the flattened values
      if king && recursed.nil? && opponents_flattened_avail.include?(king.space.id) 
        # puts "IN CHECK, so far moves are ", result
        @special_state = :check if @special_state != :checkmate
        result = compute_check_moves(color, opposite_color, result, king.space.id)
        # puts "now moves are ", result
      end
      result
    end    

    #   for each avail move for this color
    #     find other color moves again
    #     is king's square still in flattened values
    def compute_check_moves color, opp_color, available_moves, king_space_id
      new_available_moves = Hash.new {|h,k| h[k] = []}
      cur_board_state = self.get_state
      original_spaces = @spaces.deep_dup

      available_moves.each do |from, to|
        to.each do |to_space_id|
          # always look at real king space ID unless simulating new one        
          new_king_space_id = (from == king_space_id) ? to_space_id : king_space_id
          change_board_state(cur_board_state.deep_dup, original_spaces, color, opp_color, from, to_space_id)
          opponents_new_moves = get_available_moves(opp_color,recursed=true).values.flatten
          new_available_moves[from] << to_space_id if not opponents_new_moves.include? new_king_space_id
        end
      end
      self.reconstruct cur_board_state
      @special_state = :checkmate if new_available_moves.values.flatten.length == 0
      return new_available_moves
    end

    def change_board_state(board_state, original_spaces, color, opp_color, from, to)
      from_piece_type = original_spaces[from].piece.piece_type
      board_state[color].delete(from)
      board_state[color][to] = from_piece_type
      board_state[opp_color].delete(to)
      self.reconstruct(board_state)
    end

    # board state should be 
    # {:white => {1 => :pawn, 2 => :pawn}, :black => [etc]}
    # todo: error handling on bad input here (or maybe do it in game)
    def reconstruct board_state
      @spaces = {}
      self.construct_spaces
      @pieces = {:white => [], :black => []}
      board_state.each do |color, positions|
        positions.each do |space_id, piece_type|
          space = @spaces[space_id.to_i]
          piece = StarChess::Piece.new self, piece_type.to_sym, color.to_sym, space
          space.piece = piece
          @pieces[color.to_sym] << piece
        end
      end
    end

    def construct_spaces
      (1..37).each do |id|
        @spaces[id] = StarChess::Space.new(id)
      end
      StarChess::SPACE_DEFS.each do |space_id, space_def|
        [:north, :northwest, :southwest, 
        :south, :southeast, :northeast].each_with_index do |direction, index|
          if not space_def[index].nil?
            referent_space =  @spaces[space_def[index]]
            @spaces[space_id].set_adjacent(direction, referent_space) 
          end
        end
      end 
    end

    def setup_pawns
      StarChess::PAWN_SPACES.each do |color, space_list|
        space_list.each do |space_id|
          space = @spaces[space_id]
          pawn = StarChess::Piece.new self, :pawn, color, space
          space.piece = pawn
          @pieces[color] << pawn
        end
      end
    end

    def add_chosen_piece color, piece_type, space_id
      space = @spaces[space_id]
      raise StarChess::SpaceError, "space #{space_id} already has a piece" unless 
        space.piece == nil
      raise StarChess::SpaceError, "#{space_id} not a choosable space" unless 
        StarChess::CHOSEN_SPACES[color].include? space_id
      piece = StarChess::Piece.new self, piece_type, color, space
      space.piece = piece
      @pieces[color] << piece
    end

  end

  class SpaceError < RuntimeError
  end

end