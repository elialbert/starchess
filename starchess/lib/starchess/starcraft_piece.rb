require 'starchess/piece_defs'

module StarChess
  class StarcraftPiece < StarChess::Piece

    def get_pawn_moves recursed=nil
      result = []
      case @color
      when :white
        if @space.north && @space.north.piece.nil?
          result << @space.north.id if recursed.nil?
          if StarChess::PAWN_SPACES[@color].include?(@space.id) &&
            @space.north.north && @space.north.north.piece.nil?           
            result << @space.north.north.id if recursed.nil?
          end
        end
        if @space.northwest && @space.northwest.piece # allow to promote when own color
          result << @space.northwest.id if check_piece_supply(@space.northwest.piece)
        end
        if @space.northeast && @space.northeast.piece
          result << @space.northeast.id if check_piece_supply(@space.northeast.piece)
        end
      when :black 
        if @space.south && @space.south.piece.nil?
          result << @space.south.id if recursed.nil?
          if StarChess::PAWN_SPACES[@color].include?(@space.id) && 
            @space.south.south && @space.south.south.piece.nil?
            result << @space.south.south.id if recursed.nil?
          end
        end
        if @space.southwest && @space.southwest.piece
          result << @space.southwest.id if check_piece_supply(@space.southwest.piece)
        end
        if @space.southeast && @space.southeast.piece
          result << @space.southeast.id if check_piece_supply(@space.southeast.piece)
        end
      end
      result

    end

    def check_piece_supply taken_piece
      if taken_piece.color != @color
        return true
      end
      # have to make sure there are only ever 2 knights, 2 rooks, 2 bishop, 1 queen
      promotion_type = @board.get_promotion(taken_piece.piece_type)
      return false unless promotion_type # can't promote a king or queen
      return @board.count_piece_type(promotion_type, @color) < StarChess::STARCRAFT_NUM_ALLOWED[promotion_type]
    end
  end
end
