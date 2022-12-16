class AddNewGameType < ActiveRecord::Migration[4.2]
  def change
    change_table :starchess_games do |t|
      t.string :game_variant_type, :index => true
    end
  end
end
