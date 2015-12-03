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

    attr_accessor :game

    def run_AI_game
      @game = StarChess::Game.new :choose_mode, nil, nil
      color = :white
      mode = :choose_mode
      move_count = 0
      while move_count < 60
        # puts "color is #{color}, mode is #{mode}, game mode is #{@game.mode}"
        info = @game.get_game_info color
        move = mode == :choose_mode ? pick_choose_move(info, color) : pick_play_move(info, color)
        mode == :choose_mode ? do_choose_move(color, info, move) : do_play_move(color, info, move)

        color = (color == :white) ? :black : :white
        puts "move_count is #{move_count}"
        if move_count == 9
          mode = :play_mode
          @game = StarChess::Game.new mode, @game.get_game_info(:white)[:state], nil
        end
        move_count += 1
      end
      winner = find_winner @game.get_game_info(color)[:state]
      set_results winner

    end

    def pick_choose_move info, color
      # puts "available moves are #{info[:available_moves]}"
      space_id = info[:available_moves][Random.rand(0...info[:available_moves].length)]
      chosen_pieces_left = StarChess::CHOSEN_PIECE_TYPES - @game.chosen_pieces[color]
      piece = chosen_pieces_left[Random.rand(0...chosen_pieces_left.length)]
      return {:color => color, :piece_type => piece, :space_id => space_id}
    end

    def pick_play_move info, color
      # puts "available moves are #{info[:available_moves]}"
      random_from = info[:available_moves].keys()[Random.rand(0...info[:available_moves].keys().length)]
      random_to = info[:available_moves][random_from][Random.rand(0...info[:available_moves][random_from].length)] 
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

    def do_play_move color, info, move
      board_state = info[:state]
      # puts "doing play move with board state #{board_state}"
      puts "play move for #{color} is #{move}"
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
      puts points
      winner = points.max_by{|k,v| v}
      puts winner
      return winner

    end

    def set_results winner
      puts "winner is #{winner}"
    end 
  end

end
