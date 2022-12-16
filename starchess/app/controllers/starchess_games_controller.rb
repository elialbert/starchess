require "starchess/game"

class StarchessGamesController < ApiController
  def index
    # games =  StarchessGame.where("player1_id = ? or player2_id = ?", current_user.id, current_user.id).
    #   paginate(:page => params[:page]).
    #     order('updated_at desc')
    # render json: games
    head :ok
  end

  def show
    game = StarchessGame.find(params[:id])
    # quick hack to make it easy to join an open game
    if game.player2_id == 0 and current_user.id != game.player1_id
      game.player2_id = current_user.id
      game.save!
      push_to_firebase(game) if not Rails.env.test?
    end

    if (game.player1_id != current_user.id) and (game.player2_id != current_user.id)
      error!(:forbidden)
    end
    game.get_available_moves
    game.current_user_player = (current_user.id == game.player1_id) ? 'white' : 'black'
    # render json: game
    head :ok
  end

  def new_ai_ai_game
    game = StarchessGame.create(player1_id: -1, player2_id: -1,
                                ai_mode: "both", game_variant_type: "starchess_chooserandom")
    render json: game, :include => [:available_moves,:extra_state], :status => :created
  end

  def create
    params = game_create_params
    if !current_user
      if params[:player1_id] > 0 || params[:player2_id] > 0
        error!(:forbidden)
      else
        return params[:ai_mode] == 'both' ? new_ai_ai_game : error!(:forbidden)
      end
    end

    if params[:join]
      begin
        game = StarchessGame.find(params[:join])
      rescue
        error!(:forbidden)
      end
      if game.player1_id != 0 and game.player2_id == 0
        if params[:ai_mode]
          game.player2_id = -1
          game.ai_mode = 'normal'
        else
          game.player2_id = current_user.id
          push_to_firebase(game) if not Rails.env.test?
        end
        game.save
        return render json:(game)
      else
        error!(:forbidden)
      end
    end
    params[:player1_id] = current_user.id
    params[:player2_id] = 0
    params[:game_variant_type] ||= "starchess"
    @game = StarchessGame.create(params)
    bybug
    # render json: @game, {:include => [:available_moves,:extra_state], :status => :created}

  end

  def run_ai_ai_move(game)
    game.update_ai_ai(game_update_params)
    render json: game
  end

  def update
    game = StarchessGame.find(params[:id])
    return run_ai_ai_move(game) if game.player1_id == -1
    player_id_field = (game.turn == 'white') ? 'player1_id' : 'player2_id'
    if current_user.id != game[player_id_field]
      error!(:forbidden)
    end
    begin
      game.update(game_update_params)
    rescue Exception => e
      if not e.class.to_s.include? "StarChess"
        raise
      end
      error!(:bad_request, :metadata => {:error_description => e.message, :error => e.class.to_s})
    end
    game.current_user_player = (current_user.id == game.player1_id) ? 'white' : 'black'
    push_to_firebase(game) if not Rails.env.test?
    # render json: game
    head :ok
  end

  private
    def game_create_params
      params.require(:starchess_game).permit(:player1_id, :player2_id, :join, :ai_mode, :game_variant_type)
    end
    def game_update_params
      params.require(:starchess_game).permit(:board_state, :turn, :chosen_piece, :selected_move)
    end

    def push_to_firebase game
      firebase_url = Rails.env.production? ? 'https://starchess.firebaseio.com/games' : 'https://starchess.firebaseio.com/dev_games'
      firebase = Firebase::Client.new(firebase_url,
                                      ENV['FIREBASE_SECRET'])
      response = firebase.set(game.id, game)
    end
end
