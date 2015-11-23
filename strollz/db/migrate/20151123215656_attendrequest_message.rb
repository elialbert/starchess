class AttendrequestMessage < ActiveRecord::Migration
  def change
    change_table(:Attendrequests) do |t|
      t.text :message
    end
  end
end
