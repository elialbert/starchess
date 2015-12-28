require 'starchess/ai/ai_heuristic'

module StarChess
  # recursive ai using heuristic version (a lot)
  class AIRecursive
    attr_accessor :game, :color, :opp_color, :original_spaces
    def initialize(game, color, opp_color, original_spaces)
      @game, @color, @opp_color, @original_spaces = game, color, opp_color,
        original_spaces
    end

    def run(from, to, board_state, scores)
      puts "running ai for #{@color}"
      heuristic = AIHeuristic.new(@game, @color, @opp_color, @original_spaces)
      scores = heuristic.run(from, to, board_state, scores)
      puts "starting with"
      puts scores
      scores["#{from},#{to}"] += run_inner(board_state, 0, from, to, 0)
      scores
    end

    # switch colors, recreate board, rerun heuristic,
    # apply score back for that move key
    def run_inner(board_state, incremental, from, to, depth)
      available_moves, board_state = switch(board_state, from, to)
      # if opp mode, get best move and switch
      if depth.even?
        puts "avail moves for #{@color} are "
        puts available_moves
        fromm, too, inc = get_opponent_move(available_moves, board_state)
        incremental -= inc
        puts "opp move is #{fromm}, #{too} for #{from},#{to}: #{inc}"
        available_moves, board_state = switch(board_state, fromm, too)
        depth += 1
      end

      heuristic = AIHeuristic.new(@game, @color, @opp_color,
                                  @game.board.spaces.deep_dup)
      new_scores = run_all_moves(heuristic, available_moves, board_state)
      # new_scores = Hash.new { |hash, key| hash[key] = 0 }
      # available_moves.each do |fromm, to_list|
      #   to_list.each do |too|
      #     new_scores = heuristic.run(fromm, too, board_state, new_scores)
      #     if depth < 2
      #       incremental += run_inner(board_state, incremental, fromm, too, depth + 1)
      #     end
      #   end
      # end
      incremental += adjust_score(new_scores, depth)
      puts "adjusting score by #{incremental} for #{from}, #{to}"
      incremental
    end

    def switch(board_state, from, to)
      puts "about to change board state for #{@opp_color}"
      @game.board.change_board_state(
        board_state.deep_dup,
        @game.board.spaces.deep_dup,
        @color, @opp_color, from, to)
      @color, @opp_color = @opp_color, @color
      return @game.board.get_available_moves(@color.to_sym, false),
        @game.board.get_state
    end

    def adjust_score(scores, depth)
      # return -1 * scores.values.max if depth.even?
      scores.values.max
    end

    def run_all_moves(heuristic, available_moves, board_state)
      new_scores = Hash.new { |hash, key| hash[key] = 0 }
      available_moves.each do |fromm, to_list|
        to_list.each do |too|
          new_scores = heuristic.run(fromm, too, board_state, new_scores)
        end
      end
      if new_scores == {} || new_scores == nil
        byebug
      end
      new_scores
    end

    def get_opponent_move(available_moves, board_state)
      puts "getting opp move for #{@color}"
      heuristic = AIHeuristic.new(@game, @color, @opp_color,
                                  @game.board.spaces.deep_dup)
      new_scores = run_all_moves(heuristic, available_moves, board_state)
      pick_opponent_move(new_scores)
    end

    def pick_opponent_move(scores)
      available_moves_new = Hash.new { |hash, key| hash[key] = [] }
      max_score = scores.max_by{|k,v| v}[1]
      available_moves_flat = scores.select {|k,v| v == max_score}
      available_moves_flat.keys().each do |move_string|
        to, from = move_string.split(',')
        available_moves_new[to.to_i] << from.to_i
      end
      random_from = available_moves_new.keys()[Random.rand(0...available_moves_new.keys().length)]
      random_to = available_moves_new[random_from][Random.rand(0...available_moves_new[random_from].length)]
      return random_from, random_to, max_score
    end

  end
end
