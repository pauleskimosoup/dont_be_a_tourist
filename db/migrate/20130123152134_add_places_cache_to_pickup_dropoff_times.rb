class AddPlacesCacheToPickupDropoffTimes < ActiveRecord::Migration
  def self.up
    add_column :pickup_dropoff_times, :places_cache, :integer, :default => 0
  end

  def self.down
    remove_column :pickup_dropoff_times, :places_cache
  end
end
