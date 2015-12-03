module StarChess
  PAWN_SPACES = {:white => [5, 12, 18, 23, 29], 
    :black => [9, 15, 20, 26, 33]
    }
  CHOSEN_SPACES = {:white => [4, 11, 17, 22, 28],
    :black => [10, 16, 21, 27, 34]}

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
  PIECE_POINTS = {:pawn => 1, :king => 20, :queen => 12, :bishop => 5, :rook => 3, :knight => 7, nil => 0}


end