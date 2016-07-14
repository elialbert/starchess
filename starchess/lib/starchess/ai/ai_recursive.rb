require 'starchess/ai/ai_heuristic'
require 'digest/sha1'

module StarChess
  # recursive ai using heuristic version (a lot)
  class AIRecursive
    attr_accessor :game, :color, :opp_color, :original_spaces
    def initialize(game, color, opp_color, original_spaces, depth=1)
      @game, @color, @opp_color, @original_spaces, @depth = game, color, opp_color,
        original_spaces, depth
      @cache = {}
    end

    def run(from, to, board_state, scores)
      heuristic = AIHeuristic.new(@game, @color, @opp_color, @original_spaces)
      scores = heuristic.run(from, to, board_state, scores)
      incremental = run_inner(board_state.deep_dup, [], from, to, 0)
      @game.board.reconstruct(board_state)
      scores["#{from},#{to}"] += average(incremental)
      scores
    end

    # switch colors, recreate board, rerun heuristic,
    # apply score back for that move key
    def run_inner(board_state, incremental, from, to, depth)
      available_moves, board_state = switch(board_state, from, to)
      # if opp mode, get best move and switch
      if depth.even?
        fromm, too, inc = get_opponent_move(available_moves, board_state)
        return incremental if fromm.nil?
        incremental << -1 * inc
        available_moves, board_state = switch(board_state, fromm, too)
        if @game.board.special_state == 'checkmate'
          incremental << -10000
          return incremental
        end
        if @game.board.special_state == 'stalemate'
          incremental << -500
          return incremental
        end
        depth += 1
      end

      heuristic = AIHeuristic.new(@game, @color, @opp_color,
                                  @game.board.spaces.deep_dup)
      # new_scores = run_all_moves(heuristic, available_moves, board_state)
      new_scores = Hash.new { |hash, key| hash[key] = 0 }
      available_moves.each do |fromm, to_list|
        to_list.each do |too|
          # new_scores = run_memoized_heuristic(heuristic, fromm, too, board_state, new_scores)
          new_scores = heuristic.run(fromm, too, board_state, new_scores)
          if depth < @depth
            incremental += run_inner(board_state.deep_dup, incremental, fromm, too, depth + 1)
            @game.board.reconstruct(board_state)
          end
        end
      end
      incremental << (adjust_score(new_scores, depth) || 0)
      incremental
    end

    def switch(board_state, from, to)
      @game.board.change_board_state(
        board_state.deep_dup,
        @game.board.spaces.deep_dup,
        @color, @opp_color, from, to)
      @color, @opp_color = @opp_color, @color
      return @game.board.get_available_moves(@color.to_sym, nil),
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
          # new_scores = run_memoized_heuristic(heuristic, fromm, too, board_state, new_scores) # heuristic.run(fromm, too, board_state, new_scores)
          new_scores = heuristic.run(fromm, too, board_state, new_scores)
        end
      end
      new_scores
    end

    def run_memoized_heuristic(heuristic, from, to, board_state, new_scores)
      string_key = {from:from, to:to, board_state:board_state}.to_a.to_s
      cache_key = Digest::SHA1.hexdigest(string_key)
      cache_val = @cache[cache_key]
      if cache_val
        new_scores["#{from},#{to}"] = cache_val
        return new_scores
      end
      heuristic.run(from, to, board_state, new_scores)
      new_scores["#{from},#{to}"] = heuristic.cur_result
      @cache[cache_key] = heuristic.cur_result
      new_scores
    end

    def get_opponent_move(available_moves, board_state)
      heuristic = AIHeuristic.new(@game, @color, @opp_color,
                                  @game.board.spaces.deep_dup)
      new_scores = run_all_moves(heuristic, available_moves, board_state)
      return nil,nil,nil if new_scores.empty?
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

    def average(series)
      begin
        series.compact.inject(&:+) / series.length
      rescue NoMethodError
        0
      end
    end

  end
end
