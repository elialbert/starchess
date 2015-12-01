module StarChess
  class Space
    attr_accessor :north, :northwest, :southwest, 
      :south, :southeast, :northeast, :id, :piece

    def initialize space_id
      @id = space_id
    end  

    def get_piece_color
      return @piece.color if @piece 
    end

    def get_adjacent direction
      self.send("#{direction}")
    end

    def set_adjacent direction, space_obj
      self.send("#{direction}=", space_obj)
    end 
  end
end