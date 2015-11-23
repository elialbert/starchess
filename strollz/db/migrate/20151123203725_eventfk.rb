class Eventfk < ActiveRecord::Migration
  def change
    add_foreign_key :events, :users, references: :creator_id
  end
end
