require 'starchess/game'
require 'starchess/ai/ai'

class StarchessGame < ActiveRecord::Base
  include RocketPants::Cacheable
  belongs_to :player1, class_name: "User", foreign_key: "player1_id"
  belongs_to :player2, class_name: "User", foreign_key: "player2_id"

  attr_reader :logic
  attr_accessor :extra_state, :winner_id_temp, :current_user_player, :saved_selected_move
  before_create :set_board_attrs

  def extra_state
    @extra_state
  end

  def serializable_hash(options = {})
    super methods: [:available_moves, :meta_info, :extra_state]
  end

  def set_board_attrs
    if game_variant_type == "starchess"
      mode = :choose_mode
    elsif ["starchess_nochoose", "starchess_chooserandom", "starcraft"].include?(game_variant_type)
      mode = :play_mode
    end    
    @logic = StarChess::Game.new mode, nil, nil, game_variant_type
    self.turn = "white" # next move's color
    self.mode = mode.to_s
    info = @logic.get_game_info :white # get game info for next call
    self.board_state = ActiveSupport::JSON.encode(info[:state])
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
  end

  def meta_info
    player2_email = self.player2 ? self.player2.email : "Waiting for opponent"
    if self.player2_id == -1
      player2_email = "AI"
    end
    if self.player1_id == -1
      @extra_state = {:player1 => "AI", :player2 => "AI", :saved_selected_move => @saved_selected_move}
      return
    end
    @extra_state = {:player1 => self.player1.email, :player2 => player2_email,
      :special_state => @logic ? @logic.board.special_state : nil,
      :current_user_player => @current_user_player,
      :saved_selected_move => @saved_selected_move
    }
    @extra_state[:special_state] = self.mode if not @extra_state[:special_state] and self.mode == "done"
    if self.winner_id
      if self.winner_id > 0
        begin
          @extra_state[:winner] = User.find(self.winner_id).email
        rescue Exception => e
          @extra_state[:winner] = self.winner_id
        end
      elsif self.winner_id == -1
        @extra_state[:winner] = "AI"
      end
    end
  end

  def prepare_logic board_state
    board_state = ActiveSupport::JSON.decode(board_state)
    chosen_pieces = (self.mode == "choose_mode" && self.chosen_pieces) ?
      ActiveSupport::JSON.decode(self.chosen_pieces).with_indifferent_access : nil
    @logic = StarChess::Game.new self.mode.to_sym, board_state, chosen_pieces, self.game_variant_type
    return board_state
  end

  def get_available_moves
    self.prepare_logic self.board_state
    info = @logic.get_game_info self.turn.to_sym
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
  end

  def update_choose_mode attributes, color
    attributes[:chosen_piece] = ActiveSupport::JSON.decode(attributes[:chosen_piece])
    @logic.add_piece color.to_sym, attributes[:chosen_piece][:piece_type].to_sym,
      attributes[:chosen_piece][:space_id]
    if @logic.chosen_pieces.values.flatten.length == 10
      self.mode = "play_mode"
      @logic.mode = :play_mode
      attributes[:selected_move] = '["just_switched_modes"]'
    end
    attributes[:chosen_pieces] = ActiveSupport::JSON.encode(@logic.chosen_pieces)
    return attributes
  end

  def check_move_validity attributes, color
    old_board_state = (self.board_state.class == String) ? ActiveSupport::JSON.decode(self.board_state) : self.board_state
    raise StarChess::TurnError, "that move is not valid" unless
      @logic.check_move_validity(ActiveSupport::JSON.decode(attributes[:selected_move] || '[]'),
                                 ActiveSupport::JSON.decode(self.available_moves), # old available moves
                                 old_board_state, color) # old board state
  end

  def do_special_state attributes
    if @logic.board.special_state == :checkmate and not self.winner_id
      attributes[:winner_id] = (self.turn == 'white') ? self.player1_id : self.player2_id
      attributes[:mode] = "done"
    elsif @logic.board.special_state == :stalemate
      attributes[:mode] = "done"
    end
    attributes
  end

  def prepare_update_attributes_return attributes, info
    attributes[:board_state] = ActiveSupport::JSON.encode(info[:state])
    self.available_moves = ActiveSupport::JSON.encode(info[:available_moves])
    return attributes
  end

  def run_ai_mode attributes, info
    gameAI = StarChess::AI.new 'single_mode'
    gameAI.run_single_move info, @logic, attributes[:turn].to_sym
    if self.mode == 'choose_mode'
      attributes[:chosen_pieces] = ActiveSupport::JSON.encode(gameAI.game.chosen_pieces)
      if gameAI.game.mode == :play_mode
        attributes[:mode] = "play_mode"
        attributes[:selected_move] = '["just_switched_modes"]'
      end
    end
    # switch back to human player - new turn should always be white for now
    attributes[:turn] = (attributes[:turn].to_sym == :black) ? :white : :black
    # raise "turn problems" unless attributes[:turn] == :white
    info = gameAI.game.get_game_info attributes[:turn]
    @logic.board.special_state = info[:special_state]
    attributes = do_special_state attributes
    @saved_selected_move = ActiveSupport::JSON.encode(gameAI.saved_selected_move)
    attributes.delete :chosen_piece
    attributes.delete :selected_move

    return attributes, info
  end

  def update_ai_ai(attributes)
    attributes[:board_state] = prepare_logic attributes[:board_state]
    info = @logic.get_game_info(attributes[:turn])
    attributes = do_special_state attributes
    attributes, info = run_ai_mode(attributes, info) if attributes[:mode] != "done"
    attributes = prepare_update_attributes_return attributes, info
    # super update
    ActiveRecord::Base.instance_method(:update).bind(self).call(attributes)
  end

  def update(attributes={})
    attributes[:board_state] = prepare_logic attributes[:board_state]
    color = attributes[:turn]
    raise StarChess::TurnError, "it is #{color}'s turn" unless color == self.turn
    if self.mode == "choose_mode"
      attributes = update_choose_mode attributes, color
    elsif attributes[:chosen_piece] # check for pawn promotion
      @logic.do_pawn_promotion color.to_sym, ActiveSupport::JSON.decode(attributes[:chosen_piece])
    end

    @saved_selected_move = (attributes[:selected_move] or attributes[:chosen_piece]).deep_dup
    attributes[:turn] = (color.to_sym == :black) ? :white : :black
    check_move_validity attributes, color
    attributes.delete :chosen_piece
    attributes.delete :selected_move

    info = @logic.get_game_info attributes[:turn]
    attributes = do_special_state attributes

    attributes,info = run_ai_mode(attributes, info) if self.ai_mode == 'normal' and attributes[:mode] != "done"
    attributes = prepare_update_attributes_return attributes, info
    super
  end

end
