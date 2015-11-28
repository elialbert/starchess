require "starchess/game"
require 'json'

class StarchessGamesController < ApiController
  def index
    expose StarchessGame.paginate(:page => params[:page])
  end
  def show
    expose StarchessGame.find(params[:id])
  end
  def create
    @game = StarchessGame.new(game_create_params)
    @game.turn = "white"
    @game.mode = "choose_mode"
    @game.save
    expose({}, {status: :created})
  end

  def update
    @game = StarchessGame.find(params[:id])
    params = game_update_params
    chosen_pieces = json.parse(@game.chosen_pieces)
    g = StarChess::Game(params[:mode], params[:board_state], chosen_pieces)
    color = @game.turn
    opposite_color = (color == :black) ? :white : :black

    # handle errors here?
    if g.mode == "choose_mode"
      g.add_piece params[:chosen_piece][:color], params[:chosen_piece][:piece_type],
      params[:chosen_piece][:space_id]]
    end 
    info = g.get_game_info opposite_color
    expose(info)
  end

  private
    def game_create_params
      params.require(:starchess_game).permit(:player1_id, :player2_id)
    end
    def game_update_params
      params.require(:starchess_game).permit(:mode, :board_state, :turn, :chosen_piece)
    end
end