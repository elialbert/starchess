class Attendrequests < ActiveRecord::Migration
  def change
      change_table(:Attendrequests) do |t|
        t.datetime :timestamp_requested
        t.datetime :timestamp_responded
        t.integer :response
        t.references :user
        t.references :event
      end

  end
end
