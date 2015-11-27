require 'starchess/space'
require 'starchess/piece'
require 'starchess/space_defs'
require 'starchess/piece_defs'

module StarChess
  class Board
    attr_accessor :spaces, :pieces, :taken_pieces
    def initialize board_state
      @spaces = {} # int ID to Space instance
      @pieces = {:white => [], :black => []}
      @taken_pieces = {:white => [], :black => []}
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

    def get_available_moves color
      result = {}
      @pieces[color].each do |piece|
        # dict of space id => list of space ids
        result[piece.space.id] = piece.get_available_moves 
      end
      result
    end    

    # board state should be 
    # {:white => {1 => :pawn, 2 => :pawn}, :black => [etc]}
    # todo: taken, maybe
    # todo: error handling on bad input here (or maybe do it in game)
    def reconstruct board_state
      board_state.each do |color, positions|
        positions.each do |space_id, piece_type|
          space = @spaces[space_id]
          piece = StarChess::Piece.new self, piece_type, color, space
          space.piece = piece
          @pieces[color] << piece
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
            @spaces[space_id].public_send("#{direction}=", referent_space) 
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