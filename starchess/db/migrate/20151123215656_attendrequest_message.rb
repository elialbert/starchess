class AttendrequestMessage < ActiveRecord::Migration[4.2]
  def change
    change_table(:attendrequests) do |t|
      t.text :message
    end
  end
end
