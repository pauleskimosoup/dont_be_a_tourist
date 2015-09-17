class AddRoomNotesToTrips < ActiveRecord::Migration
	
  def self.up
    add_column :trips, :room_notes, :text
  end
	
  def self.down
    remove_column :trips, :room_notes
  end
  
end