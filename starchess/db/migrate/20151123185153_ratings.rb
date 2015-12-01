class Ratings < ActiveRecord::Migration
  def change
    change_table(:ratings) do |t|
      t.belongs_to :user_from, index: true
      t.belongs_to :user_to, index: true
      t.integer :score
      t.string :blurb
      t.references :event
      t.boolean :from_creator
    end   
  end
end
