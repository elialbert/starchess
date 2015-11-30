require "starchess/game"

class StarchessGamesController < ApiController
  def index
    #  in case we only want to show games for authed user
    #  .where("player1_id = ? or player2_id = ?", current_user.id, current_user.id)
    expose StarchessGame.paginate(:page => params[:page])
  end

  def show
    game = StarchessGame.find(params[:id])
    game.get_available_moves
    expose game
  end
  
  def create
    @game = StarchessGame.create(game_create_params)
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
      params.require(:starchess_game).permit(:player1_id, :player2_id)
    end
    def game_update_params
      params.require(:starchess_game).permit(:board_state, :turn, :chosen_piece, :selected_move)
    end
end