require 'starchess/game'

class StarchessGame < ActiveRecord::Base
  include RocketPants::Cacheable
  belongs_to :player1, class_name: "User", foreign_key: "player1_id"
  belongs_to :player2, class_name: "User", foreign_key: "player2_id"

  attr_reader :logic
  attr_accessor :extra_state
  before_create :set_board_attrs

  def extra_state
    @extra_state
  end

  def attributes
    info = {:available_moves => self.available_moves, :extra_state => @extra_state}
    super.merge info
  end

  def serializable_hash(options = {})
    super methods: [:available_moves, :extra_state]
  end

  def set_board_attrs
    @logic = StarChess::Game.new :choose_mode, nil, nil
    self.turn = "white" # next move's color
    self.mode = "choose_mode"
    info = @logic.get_game_info :white # get game info for next call
    self.board_state = ActiveSupport::JSON.encode(info[:state])
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
    self.prepare_extra_state
  end

  def prepare_extra_state
    @extra_state = {:player1 => self.player1.email, :player2 => self.player2.email, :special_state => @logic.board.special_state}
  end

  def prepare_logic board_state
    board_state = ActiveSupport::JSON.decode(board_state)
    chosen_pieces = (self.mode == "choose_mode" && self.chosen_pieces) ? 
      ActiveSupport::JSON.decode(self.chosen_pieces).with_indifferent_access : nil
    @logic = StarChess::Game.new self.mode.to_sym, board_state, chosen_pieces
    return board_state
  end

  def get_available_moves
    self.prepare_logic self.board_state
    info = @logic.get_game_info self.turn.to_sym
    self.prepare_extra_state
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
  end

  def update(attributes={})
    attributes[:board_state] = prepare_logic attributes[:board_state]
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
        attributes[:selected_move] = '["just_switched_modes"]'
      end
      attributes[:chosen_pieces] = ActiveSupport::JSON.encode(@logic.chosen_pieces)
    end 
    attributes.delete :chosen_piece
    opposite_color = (color.to_sym == :black) ? :white : :black
    attributes[:turn] = opposite_color
    raise StarChess::TurnError, "that move is not valid" unless 
      @logic.check_move_validity(ActiveSupport::JSON.decode(attributes[:selected_move] || '[]'),
                                 ActiveSupport::JSON.decode(self.available_moves)) # old available moves
    attributes.delete :selected_move
    info = @logic.get_game_info opposite_color
    attributes[:board_state] = ActiveSupport::JSON.encode(info[:state])
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])    
    self.prepare_extra_state    
    super
  end

end
