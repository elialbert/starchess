class StarchessGameChosenPieces < ActiveRecord::Migration[4.2]
  def change
    change_table(:starchess_games) do |t|
      t.text :chosen_pieces
    end
  end
end
