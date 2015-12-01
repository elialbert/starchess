class AddUserEventRefs < ActiveRecord::Migration
  def change
    add_reference :events, :creator, references: :users, index: true
    create_table :events_users, id: false do |t|
      t.belongs_to :event, references: :attendees, index: true
      t.belongs_to :user, references: :attending, index: true
    end
  end
end
