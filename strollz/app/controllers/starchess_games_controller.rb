require "starchess/game"

class StarchessGamesController < ApiController
  def index
    expose StarchessGame.paginate(:page => params[:page])
  end

  def show
    expose StarchessGame.find(params[:id])
  end
  
  def create
    @game = StarchessGame.create(game_create_params)
    expose(@game, {:include => :available_moves, :status => :created})
  end

  def update
    @game = StarchessGame.find(params[:id])
    @game.update(game_update_params)
    expose(@game, {:include => [:available_moves,:special_state], :status => :updated})
  end

  private
    def game_create_params
      params.require(:starchess_game).permit(:player1_id, :player2_id)
    end
    def game_update_params
      params.require(:starchess_game).permit(:board_state, :turn, :chosen_piece)
    end
end