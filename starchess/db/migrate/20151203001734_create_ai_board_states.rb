class CreateAiBoardStates < ActiveRecord::Migration
  def change
    create_table :ai_board_states do |t|
      t.string :state, :limit => 1000
      t.integer :score
      t.timestamps null: false
    end
    add_index :ai_board_states, [:state]
  end
end
