class AttendrequestMessage < ActiveRecord::Migration
  def change
    change_table(:attendrequests) do |t|
      t.text :message
    end
  end
end
