class CreateRatings < ActiveRecord::Migration[4.2]
  def change
    create_table :ratings do |t|

      t.timestamps null: false
    end
  end
end
