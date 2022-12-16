class ChangeDefaultForAiBoardStates < ActiveRecord::Migration[4.2]
  def change
    change_column :ai_board_states, :score, :integer, :default => 0
  end
end
