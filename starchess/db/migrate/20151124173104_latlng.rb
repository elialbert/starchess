class Latlng < ActiveRecord::Migration[4.2]
  def change
    add_column(:users, :lat, :float)
    add_column(:users, :lng, :float)
    add_column(:events, :lat, :float)
    add_column(:events, :lng, :float)    
  end
end
