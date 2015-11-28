require 'starchess/game'

class StarchessGame < ActiveRecord::Base
  include RocketPants::Cacheable
  has_one :player1, class_name: "User", foreign_key: "id"
  has_one :player2, class_name: "User", foreign_key: "id"

  attr_reader :logic
  # attr_accessor :mode, :turn, :board_state, :chosen_pieces, :available_moves
  attr_accessor :available_moves
  before_create :set_board_attrs

  def available_moves
    @available_moves
  end

  def attributes
    info = {:available_moves => @available_moves}
    super.merge info
  end

  def serializable_hash(options = {})
    super methods: :available_moves
  end

  def set_board_attrs
    @logic = StarChess::Game.new :choose_mode, nil, nil
    self.turn = "white" # current move's color, next call must be different
    self.mode = "choose_mode"
    info = @logic.get_game_info :black # get game info for next call
    self.board_state = ActiveSupport::JSON.encode(info[:state])
    @available_moves = ActiveSupport::JSON.encode(info[:available_moves])
  end

  def update(attributes={})
    attributes[:board_state] = ActiveSupport::JSON.decode(attributes[:board_state])
    chosen_pieces = (self.mode == "choose_mode" && self.chosen_pieces) ? 
      ActiveSupport::JSON.decode(self.chosen_pieces) : nil
    @logic = StarChess::Game.new self.mode, attributes[:board_state], chosen_pieces
    color = attributes[:turn]
    raise StarChess::TurnError, "it is #{color}'s turn" unless color != self.turn

    # handle errors here / check integrity too
    if self.mode == "choose_mode"
      attributes[:chosen_piece] = ActiveSupport::JSON.decode(attributes[:chosen_piece])
      @logic.add_piece color.to_sym, attributes[:chosen_piece][:piece_type].to_sym,
        attributes[:chosen_piece][:space_id]
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
