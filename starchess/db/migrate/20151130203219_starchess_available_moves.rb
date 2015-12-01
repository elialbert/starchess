class StarchessAvailableMoves < ActiveRecord::Migration
  def change
    change_table(:starchess_games) do |t|
      t.string :available_moves, :limit => 700
    end
  end
end
