class Uniqueness < ActiveRecord::Migration[4.2]
  def change
    add_index :events_users, [:event_id, :user_id], :unique => true, :name => "by event and user"
  end
end
