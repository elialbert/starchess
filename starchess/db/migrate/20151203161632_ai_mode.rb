class AiMode < ActiveRecord::Migration
  def change
    change_table :starchess_games do |t|
      t.string :ai_mode
    end
  end
end
