class AttendrequestOldtimestamps < ActiveRecord::Migration[4.2]
  def change
    remove_column :attendrequests, :timestamp_requested
    remove_column :attendrequests, :timestamp_responded

  end
end
