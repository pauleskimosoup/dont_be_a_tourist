class AddNoRoomsToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :no_rooms, :boolean
  end

  def self.down
    remove_column :trips, :no_rooms
  end
end
