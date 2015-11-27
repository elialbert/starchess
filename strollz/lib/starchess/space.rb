module StarChess
  class Space
    attr_accessor :north, :northwest, :southwest, 
      :south, :southeast, :northeast, :id

    def initialize space_id
      @id = space_id
    end  
  end
end