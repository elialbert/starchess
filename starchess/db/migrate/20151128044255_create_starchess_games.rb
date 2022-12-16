class CreateStarchessGames < ActiveRecord::Migration[4.2]
  def change
    create_table :starchess_games do |t|
      t.string :turn
      t.string :mode
      t.string :board_state

      t.timestamps null: false
    end
  add_reference :starchess_games, :winner, references: :users, index: true, null: true
  add_reference :starchess_games, :player1, references: :users, index: true
  add_reference :starchess_games, :player2, references: :users, index: true

  end
end
