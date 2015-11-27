module StarChess
  class Piece
    attr_accessor :piece_type, :taken, :space, :color

    def initialize board, piece_type, color, space
      @board = board
      @piece_type = piece_type
      @color = color
      @taken = false
      @space = space
    end

    def get_available_moves
      self.send("get_#{@piece_type}_moves")
    end

    def get_pawn_moves
      result = []
      case @color
      when :white
        if @space.north && @space.north.piece.nil?
          result << @space.north.id
          if StarChess::PAWN_SPACES[@color].include?(@space.id) &&
            @space.north.north && @space.north.north.piece.nil?           
            result << @space.north.north.id
          end
        end
        if @space.northwest && @space.northwest.get_piece_color == :black
          result << @space.northwest.id
        end
        if @space.northeast && @space.northeast.get_piece_color == :black
          result << @space.northeast.id
        end
      when :black 
        if @space.south && @space.south.piece.nil?
          result << @space.south.id
          if StarChess::PAWN_SPACES[@color].include?(@space.id) && 
            @space.south.south && @space.south.south.piece.nil?
            result << @space.south.south.id
          end
        end
        if @space.southwest && @space.southwest.get_piece_color == :white
          result << @space.southwest.id
        end
        if @space.southeast && @space.southeast.get_piece_color == :white
          result << @space.southeast.id
        end
      end
      result
    end

    def get_queen_moves
      result = []
      StarChess::DIRECTIONS.each do |direction|
        cur_space = @space
        while true
          cur_space = cur_space.public_send("#{direction}")
          break if cur_space.nil? 
          if cur_space.piece.nil?  
            result << cur_space.id 
          else
            break if cur_space.piece.color == @color
            result << cur_space.id 
            break             
          end
        end 
      end
      result
    end

    def get_king_moves
    end

    def get_rook_moves
    end

    def get_knight_moves
    end

    def get_bishop_moves
    end
  end
end