class CreateAttendrequests < ActiveRecord::Migration[4.2]
  def change
    create_table :attendrequests do |t|

      t.timestamps null: false
    end
  end
end
