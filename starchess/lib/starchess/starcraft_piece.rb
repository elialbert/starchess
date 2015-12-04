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
          result << @space.northwest.id
        end
        if @space.northeast && @space.northeast.piece
          result << @space.northeast.id
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
          result << @space.southwest.id
        end
        if @space.southeast && @space.southeast.piece
          result << @space.southeast.id
        end
      end
      result

    end
  end
end
