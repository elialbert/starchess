class AiMode < ActiveRecord::Migration[4.2]
  def change
    change_table :starchess_games do |t|
      t.string :ai_mode
    end
  end
end
