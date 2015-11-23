class AttendrequestOldtimestamps < ActiveRecord::Migration
  def change
    remove_column :Attendrequests, :timestamp_requested
    remove_column :Attendrequests, :timestamp_responded

  end
end
