require 'starchess/board'

module StarChess
  class Game
    attr_reader :board
    def initialize
      @board = StarChess::Board.new
    end
  end
end