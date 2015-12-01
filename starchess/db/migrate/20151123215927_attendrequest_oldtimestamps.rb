class AttendrequestOldtimestamps < ActiveRecord::Migration
  def change
    remove_column :attendrequests, :timestamp_requested
    remove_column :attendrequests, :timestamp_responded

  end
end
