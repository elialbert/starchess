require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'

module StarChess
  class Board
    attr_accessor :spaces, :pieces, :special_state
    def initialize(board_state = nil, mode = :choose_mode, random_pieces = false)
      @piece_class = StarChess::Piece
      @spaces = {}.with_indifferent_access # int ID to Space instance
      @pieces = {:white => [], :black => []}.with_indifferent_access
      @special_state = nil
      self.construct_spaces
      board_state ? self.reconstruct(board_state) : self.setup_board(mode, random_pieces)
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

    def print_pieces color
      @pieces[color].each do |piece|
        puts("huh #{piece.piece_type}: #{piece.space.id}")
      end
    end

    def get_king_piece color
      res = @pieces[color].select {|piece| piece.piece_type == :king}[0]
      byebug if res.nil? || res == []
      res
    end

    def get_available_moves(color, recursed = nil)
      result = {}
      king = nil
      opposite_color = (color == :black) ? :white : :black

      opponents_flattened_avail = get_available_moves(
        opposite_color, true).values.flatten if not recursed
      @pieces[color].each do |piece|
        # dict of space id => list of space ids
        if (piece.piece_type == :king)
          result[piece.space.id] = piece.get_king_moves(
                                          opponents_flattened_avail,
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

      if king && recursed.nil?
        result = compute_check_moves(color, opposite_color, result, king.space.id)
        if opponents_flattened_avail.include?(king.space.id)
          if @special_state.nil?
            @special_state = :check
          elsif @special_state == :stalemate
            @special_state = :checkmate
          end
        end
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
          opponents_new_moves = self.get_available_moves(opp_color,recursed=true).values.flatten
          new_available_moves[from] << to_space_id if not opponents_new_moves.include? new_king_space_id
        end
      end
      self.reconstruct cur_board_state
      @special_state = :stalemate if new_available_moves.values.flatten.length == 0
      return new_available_moves
    end

    def change_board_state(board_state, original_spaces, color, opp_color, from, to)
      if not original_spaces[from].piece
        from_piece_type = :pawn
      else
        from_piece_type = original_spaces[from].piece.piece_type
      end
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
      @pieces = {:white => [], :black => []}.with_indifferent_access
      board_state.each do |color, positions|
        positions.each do |space_id, piece_type|
          space = @spaces[space_id.to_i]
          piece = @piece_class.new self, piece_type.to_sym, color.to_sym, space
          space.piece = piece
          @pieces[color.to_sym] << piece
        end
      end
      @special_state = nil
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
          pawn = @piece_class.new self, :pawn, color, space
          space.piece = pawn
          @pieces[color] << pawn
        end
      end
    end

    def setup_board(mode, random_pieces = false)
      setup_pawns
      return if mode == :choose_mode
      StarChess::NO_CHOOSE_SETUP.each do |color, piece_map|
        pieces_list = StarChess::CHOSEN_PIECE_TYPES.deep_dup
        piece_map.each do |space_id, piece_type|
          space = @spaces[space_id]
          if random_pieces
            piece_type = pieces_list.sample
            pieces_list.delete(piece_type)
          end
          piece = @piece_class.new self, piece_type, color, space
          space.piece = piece
          @pieces[color] << piece
        end
      end
    end

    # should take current turn color
    def check_pawn_promotion color
      opposite_color = (color == :black) ? :white : :black
      StarChess::CHOSEN_SPACES[opposite_color].each do |space_id|
        if piece = @spaces[space_id].piece and piece.piece_type == :pawn
          return space_id
        end
      end
      return
    end

    def do_pawn_promotion color, space_id, piece_type
      board_state = get_state
      board_state[color][space_id] = piece_type
      self.reconstruct(board_state)
    end

    def add_chosen_piece color, piece_type, space_id
      space = @spaces[space_id]
      raise StarChess::SpaceError, "space #{space_id} already has a piece" unless
        space.piece == nil
      raise StarChess::SpaceError, "#{space_id} not a choosable space" unless
        StarChess::CHOSEN_SPACES[color].include? space_id
      piece = @piece_class.new self, piece_type, color, space
      space.piece = piece
      @pieces[color] << piece
    end

  end

  class SpaceError < RuntimeError
  end

end
