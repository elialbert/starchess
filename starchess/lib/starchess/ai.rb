require 'starchess/game'
require 'starchess/piece_defs'

module StarChess
  class AI
    # the idea is to create a runner that plays many games of ai vs ai 
    # each game keeps track of each board state
    # moves start out as random + simple heuristics
    # after a set # of moves (or checkmate/stalemate), count points based on remaining pieces
    # for each board state from the winning player, increment that state's score
    # decrement the loser's states
    # the ai simply looks for the given board state of each possible move,
    # and chooses randomly from the ones with the highest score

    attr_accessor :game, :state_store
    def initialize run_mode='store_mode'
      @run_mode = run_mode
      @results_tally = Hash.new { |hash, key| hash[key] = 0 }
      Rails.logger.level = 3 if (run_mode != 'single_mode')
      @hit_count = 0
    end

    def run_many_games n
      (1...n).each do |x|
        run_AI_game()
      end
      puts "final state store count is #{AiBoardState.count}"
      puts "final tally is #{@results_tally}"
      puts "hit count is @hit_count"
    end

    def run_AI_game
      @game = StarChess::Game.new :choose_mode, nil, nil
      @state_store = {:white => [], :black => []}
      color = :white
      mode = :choose_mode
      move_count = 0
      winner = nil
      while move_count < 60
        # puts "color is #{color}, mode is #{mode}, game mode is #{@game.mode}"
        info = @game.get_game_info color
        @state_store[color] << normalize_state(info[:state])

        if info[:special_state] == "checkmate"
          winner = (color == :white) ? :black : :white
          break
        end

        if info[:available_moves].length == 0
          break
        end

        move = mode == :choose_mode ? pick_choose_move(info, color) : pick_play_move(info, color)
        mode == :choose_mode ? do_choose_move(color, info, move) : do_play_move(color, info, move)

        color = (color == :white) ? :black : :white
        # puts "move_count is #{move_count}"
        if move_count == 9
          mode = :play_mode
          @game = StarChess::Game.new mode, @game.get_game_info(:white)[:state], nil
        end
        move_count += 1

      end
      winner = find_winner @game.get_game_info(color)[:state] if not winner
      set_results winner if @run_mode == 'store_mode'
      tally_results winner if @run_mode == 'test_mode'

    end

    # run the "AI" from the frontend. color is always black for now.
    def run_single_move info, game
      color = :black
      @game = game
      move = @game.mode == :choose_mode ? pick_choose_move(info, color) : pick_play_move(info, color)
      @game.mode == :choose_mode ? do_choose_move(color, info, move) : do_play_move(color, info, move)
      if @game.chosen_pieces[color].length == 5
        @game.mode = :play_mode
      end
    end

    def pick_choose_move info, color
      space_id = info[:available_moves][Random.rand(0...info[:available_moves].length)]
      chosen_pieces_left = StarChess::CHOSEN_PIECE_TYPES - @game.chosen_pieces[color].map(&:to_sym)
      piece = chosen_pieces_left[Random.rand(0...chosen_pieces_left.length)]
      return {:color => color, :piece_type => piece, :space_id => space_id}
    end

    def pick_play_move info, color
      # puts "available moves are #{info[:available_moves]}"
      if @run_mode == 'test_mode'
        if color == :black
          available_moves = find_highest_state_moves color, info[:available_moves], info[:state]
        else
          available_moves = info[:available_moves]          
        end
      else
        available_moves = info[:available_moves]
      end
      random_from = available_moves.keys()[Random.rand(0...available_moves.keys().length)]
      random_to = available_moves[random_from][Random.rand(0...available_moves[random_from].length)] 
      piece_type = info[:state][color][random_from]
      return {:from => random_from, :to => random_to, :piece_type => piece_type}
    end

    def do_choose_move color, info, chosen_piece
      previous_state = info[:state]
      # puts "got state #{previous_state}"
      g = StarChess::Game.new :choose_mode, previous_state, @game.chosen_pieces
      g.add_piece chosen_piece[:color], chosen_piece[:piece_type], chosen_piece[:space_id]
      @game = g
    end

    def find_highest_state_moves color, available_moves, board_state
      available_moves_new = Hash.new { |hash, key| hash[key] = [] }
      available_moves_score_count = {}
      available_moves.each do |from, to_list|
        to_list.each do |to|
          piece_type = board_state[color][from]
          state = board_state.deep_dup
          state[color].delete(from)
          state[color][to] = piece_type
          opp_color = (color == :white) ? :black : :white
          state[opp_color].delete(to)
          state = normalize_state state
          # puts "lookup looks like #{ActiveSupport::JSON.encode(state)}" 
          stored = AiBoardState.where(:state => ActiveSupport::JSON.encode(state)).first
          if stored
            puts "HIT"
            @hit_count += 1
          end
          score = stored ? stored.score : 0
          available_moves_score_count["#{from},#{to}"] = score
        end
      end
      max_score = available_moves_score_count.max_by{|k,v| v}[1]
      available_moves_flat = available_moves_score_count.select {|k,v| v == max_score}
      available_moves_flat.keys().each do |move_string|
        to, from = move_string.split(',')
        available_moves_new[to.to_i] << from.to_i
      end
      # puts "found available moves new: #{available_moves_new}"
      # puts "score count was #{available_moves_score_count}"
      return available_moves_new
    end

    def do_play_move color, info, move
      board_state = info[:state]
      # puts "doing play move with board state #{board_state}"
      # puts "play move for #{color} is #{move}"
      board_state[color].delete(move[:from])
      board_state[color][move[:to]] = move[:piece_type]
      opp_color = (color == :white) ? :black : :white
      board_state[opp_color].delete(move[:to])

      # puts "got new play state #{board_state}"
      @game = StarChess::Game.new :play_mode, board_state, nil

    end

    def find_winner board_state
      points = {:white => 0, :black => 0}
      [:white,:black].each do |color|
        board_state[color].values().each do |piece_type|
          points[color] += StarChess::PIECE_POINTS[piece_type]
        end 
      end 
      puts "white: #{points[:white]}, black: #{points[:black]}"
      winner = points.max_by{|k,v| v}
      return winner

    end

    # 99% sure states will always be sorted internally when they get here
    # if not we need to sort them
    def set_results winner
      winner = winner[0]
      loser = (winner == :white) ? :black : :white
      @state_store[winner].each do |state|
        state = ActiveSupport::JSON.encode(state)
        ai_board_state = AiBoardState.find_or_create_by(state: state)
        ai_board_state.score += 1
        ai_board_state.save!
      end

      @state_store[loser].each do |state|
        state = ActiveSupport::JSON.encode(state)
        ai_board_state = AiBoardState.find_or_create_by(state: state)
        ai_board_state.score -= 1
        ai_board_state.save!  
      end 
      puts "finished storing!"
    end 
  

    def normalize_state state
      new_state = {:white => {}, :black => {}}
      [:white, :black].each do |color|
        keys = state[color].keys.sort
        keys.each do |key|
          new_state[color][key] = state[color][key]
        end
      end
      new_state
    end

    def tally_results winner
      @results_tally[winner[0]] += 1
    end
  end

end
