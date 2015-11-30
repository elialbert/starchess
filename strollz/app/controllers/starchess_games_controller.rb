require "starchess/game"

class StarchessGamesController < ApiController
  def index
    expose StarchessGame.where("player1_id = ? or player2_id = ?", current_user.id, current_user.id).paginate(:page => params[:page])
  end

  def show
    game = StarchessGame.find(params[:id])
    if game.player1_id != current_user.id or game.player2_id != current_user.id
      error!(:forbidden)
    end
    game.get_available_moves
    expose game
  end
  
  def create
    params = game_create_params
    if params[:join]
      begin
        game = StarchessGame.find(params[:join])
      rescue 
        error!(:forbidden)
      end
      if game.player1_id != 0 and game.player2_id == 0
        game.player2_id = current_user.id
        game.save
        return expose(game)
      else
        error!(:forbidden)
      end
    end
    params[:player1_id] = current_user.id
    params[:player2_id] = 0
    @game = StarchessGame.create(params)
    expose(@game, {:include => [:available_moves,:extra_state], :status => :created})
  end

  def update
    @game = StarchessGame.find(params[:id])
    player_id_field = (@game.turn == 'white') ? 'player1_id' : 'player2_id'
    if current_user.id != @game[player_id_field]
      error!(:forbidden)
    end
    begin 
      @game.update(game_update_params)
    rescue Exception => e
      error!(:bad_request, :metadata => {:error_description => e.message, :error => e.class.to_s})
    end
    expose(@game, {:include => [:available_moves,:extra_state]})
  end

  private
    def game_create_params
      params.require(:starchess_game).permit(:player1_id, :player2_id, :join)
    end
    def game_update_params
      params.require(:starchess_game).permit(:board_state, :turn, :chosen_piece, :selected_move)
    end
end