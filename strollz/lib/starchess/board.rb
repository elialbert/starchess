require 'starchess/space'

module StarChess
  class Board
    attr_accessor :spaces, :pieces, :taken_pieces
    def initialize
      @spaces = {} # int ID to Space instance
      @pieces = {:white => [], :black => []}
      @taken_pieces = {:white => [], :black => []}
      self.construct_spaces
    end

    def construct_spaces
      (1..37).each do |id|
        @spaces[id] = StarChess::Space.new(id)
      end
      @spaces[1].northeast = @spaces[3]
    end
  end
end