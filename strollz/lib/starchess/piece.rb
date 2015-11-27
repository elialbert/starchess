module StarChess
  class Piece
    attr_accessor :piece_type, :taken, :space, :color

    def initialize piece_type, color, space
      @piece_type = piece_type
      @color = color
      @taken = false
      @space = space
    end
  end
end