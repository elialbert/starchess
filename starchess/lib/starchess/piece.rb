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

    def to_s
      "#{@piece_type} - #{@color}"
    end

    def get_available_moves
      self.send("get_#{@piece_type}_moves")
    end

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
        if @space.northwest && @space.northwest.get_piece_color == :black
          result << @space.northwest.id
        end
        if @space.northeast && @space.northeast.get_piece_color == :black
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
      return self.get_standard_moves StarChess::DIRECTIONS
    end

    # new rook move behavior: allow for 1 diagonal move along with all the
    # standard up and down. can still only take up and down tho.
    def get_rook_moves
      result = get_standard_moves [:north, :south]
      [:northwest, :northeast, :southwest, :southeast].each do  |direction|
        diagonal_adjacent = @space.get_adjacent(direction)
        next if diagonal_adjacent.nil?
        result << diagonal_adjacent.id if diagonal_adjacent.piece.nil?
      end
      result
    end

    def get_knight_moves
      result = []
      StarChess::DIRECTIONS.each do |direction|
        if @space.get_adjacent(direction) &&
          @space.get_adjacent(direction).get_adjacent(direction)
          new_directions = StarChess::KNIGHT_MOVES[direction]
          new_directions.each do |new_direction|
            new_space = @space.get_adjacent(direction).get_adjacent(direction).get_adjacent(new_direction)
            next unless new_space
            if new_space.piece.nil? || new_space.piece.color != @color
              result << new_space.id
            end
          end
        end
      end
      result
    end

    def get_bishop_moves
      return self.get_standard_moves [:northwest, :southwest, :southeast, :northeast]
    end

    def get_king_moves opponents_flattened_avail=nil, recursed=nil
      result = []
      takeable_pieces = []
      StarChess::DIRECTIONS.each do |direction|
        new_space = @space.get_adjacent(direction)
        next if new_space.nil?
        if new_space.piece.nil?
          result << new_space.id
        else
          next if new_space.piece.color == @color
          result << new_space.id
          takeable_pieces << new_space.piece
        end
      end
      # puts "in get king moves with recursed #{recursed} and result #{result}"
      return result if recursed == true
      # first remove opponent's moves
      opposite_color = (@color == :black) ? :white : :black
      opponents_flattened_avail ||= @board.get_available_moves(opposite_color, true).values.flatten
      result = result - opponents_flattened_avail
      # puts "now result is ", result
      # temporarily change color of takeable pieces and recalculate opp moves
      takeable_pieces.each do |piece|
        piece.color = @color
        @board.pieces[opposite_color].delete(piece)
        @board.pieces[color] << piece
        result = result - @board.get_available_moves(opposite_color, true).values.flatten
        piece.color = opposite_color
        @board.pieces[color].delete(piece)
        @board.pieces[opposite_color] << piece
      end
      # puts "now result is ", result
      result
    end

    def get_standard_moves directions
      result = []
      directions.each do |direction|
        cur_space = @space
        while true
          cur_space = cur_space.get_adjacent(direction)
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
  end
end
