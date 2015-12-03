class ChangeDefaultForAiBoardStates < ActiveRecord::Migration
  def change
    change_column :ai_board_states, :score, :integer, :default => 0
  end
end
