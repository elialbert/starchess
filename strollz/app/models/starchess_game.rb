require 'starchess/game'

class StarchessGame < ActiveRecord::Base
  include RocketPants::Cacheable
  has_one :player1, class_name: "User", foreign_key: "id"
  has_one :player2, class_name: "User", foreign_key: "id"

  attr_reader :logic
  attr_accessor :available_moves, :special_state
  before_create :set_board_attrs

  def available_moves
    @available_moves
  end
  def special_state
    @special_state
  end

  def attributes
    info = {:available_moves => @available_moves, :special_state => @special_state}
    super.merge info
  end

  def serializable_hash(options = {})
    super methods: [:available_moves, :special_state]
  end

  def set_board_attrs
    @logic = StarChess::Game.new :choose_mode, nil, nil
    self.turn = "white" # next move's color
    self.mode = "choose_mode"
    info = @logic.get_game_info :white # get game info for next call
    self.board_state = ActiveSupport::JSON.encode(info[:state])
    @available_moves = ActiveSupport::JSON.encode(info[:available_moves])
  end

  def update(attributes={})
    attributes[:board_state] = ActiveSupport::JSON.decode(attributes[:board_state])
    chosen_pieces = (self.mode == "choose_mode" && self.chosen_pieces) ? 
      ActiveSupport::JSON.decode(self.chosen_pieces).with_indifferent_access : nil
    @logic = StarChess::Game.new self.mode, attributes[:board_state], chosen_pieces
    color = attributes[:turn]
    raise StarChess::TurnError, "it is #{color}'s turn" unless color == self.turn

    # handle errors here / check integrity too
    if self.mode == "choose_mode"
      attributes[:chosen_piece] = ActiveSupport::JSON.decode(attributes[:chosen_piece])
      @logic.add_piece color.to_sym, attributes[:chosen_piece][:piece_type].to_sym,
        attributes[:chosen_piece][:space_id]
      if @logic.chosen_pieces.values.flatten.length == 10
        self.mode = "play_mode"
        @logic.mode = :play_mode
      end
      attributes[:chosen_pieces] = ActiveSupport::JSON.encode(@logic.chosen_pieces)
    end 
    attributes.delete :chosen_piece
    opposite_color = (color.to_sym == :black) ? :white : :black
    attributes[:turn] = opposite_color
    info = @logic.get_game_info opposite_color
    attributes[:board_state] = ActiveSupport::JSON.encode(info[:state])
    @available_moves = ActiveSupport::JSON.encode(info[:available_moves])    
    super
  end

end
