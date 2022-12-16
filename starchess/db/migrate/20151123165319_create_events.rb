class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :image
      t.timestamps null: false
      t.integer :min_attendees
      t.integer :max_attendees
      t.datetime :start_time
      t.datetime :end_time
    end
  end
end
