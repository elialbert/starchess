class CreateAttendrequests < ActiveRecord::Migration
  def change
    create_table :attendrequests do |t|

      t.timestamps null: false
    end
  end
end
