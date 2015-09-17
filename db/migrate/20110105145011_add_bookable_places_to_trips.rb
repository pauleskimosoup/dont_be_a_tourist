class AddBookablePlacesToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :bookable_places, :integer
  end

  def self.down
    remove_column :trips, :bookable_places
  end
end
