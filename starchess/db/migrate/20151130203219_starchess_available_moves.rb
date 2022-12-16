class StarchessAvailableMoves < ActiveRecord::Migration[4.2]
  def change
    change_table(:starchess_games) do |t|
      t.string :available_moves, :limit => 700
    end
  end
end
