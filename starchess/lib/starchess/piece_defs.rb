module StarChess
  PAWN_SPACES = {:white => [5, 12, 18, 23, 29],
    :black => [9, 15, 20, 26, 33]
    }
  STARCRAFT_SETUP = {:white => {11 => :king, 4 => :pawn, 5 => :pawn, 12 => :pawn}, 
                     :black => {27 => :king, 26 => :pawn, 33 => :pawn, 34 => :pawn}}
  CHOSEN_SPACES = {:white => [4, 11, 17, 22, 28],
    :black => [10, 16, 21, 27, 34]}
  NO_CHOOSE_SETUP = {:white => {4 => :king, 11 => :queen, 
                       17 => :rook, 22 => :bishop, 28 => :knight}, 
                     :black => {10 => :knight, 16 => :bishop,
                       21 => :rook, 27 => :queen, 34 => :king}}

  PIECE_TYPES = [:pawn, :king, :queen, :bishop, :rook, :knight]
  CHOSEN_PIECE_TYPES = [:king, :queen, :bishop, :rook, :knight]
  DIRECTIONS = [:north, :northwest, :southwest,
      :south, :southeast, :northeast]

  KNIGHT_MOVES = {:north => [:northeast, :northwest],
                  :northwest => [:north, :southwest],
                  :southwest => [:northwest, :south],
                  :south => [:southwest, :southeast],
                  :southeast => [:south, :northeast],
                  :northeast => [:southeast, :north]
  }
  PIECE_POINTS = {:pawn => 1, :king => 9, :queen => 12, :bishop => 5, :rook => 6, :knight => 7, nil => 0}
  PROMOTION_PIECE_POINTS = {:pawn => 5, :knight => 6, :rook => 7, :queen => 10}
  STARCRAFT_PROMOTIONS = {:pawn => :knight, :knight => :bishop, :bishop => :rook, :rook => :queen}
  STARCRAFT_NUM_ALLOWED = {:knight => 2, :bishop => 2, :rook => 2, :queen => 1}

end
