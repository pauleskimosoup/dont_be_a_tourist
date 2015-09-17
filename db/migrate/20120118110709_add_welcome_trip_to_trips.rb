class AddWelcomeTripToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :welcome_trip, :boolean, :default => false
  end

  def self.down
    remove_column :trips, :welcome_trip
  end
end
