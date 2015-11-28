class StarchessGameChosenPieces < ActiveRecord::Migration
  def change
    change_table(:starchess_games) do |t|
      t.text :chosen_pieces
    end
  end
end
