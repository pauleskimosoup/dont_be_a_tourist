class CreateAccommodationsTrips < ActiveRecord::Migration
  def self.up
    create_table :accommodations_trips, :id => false, :force => true do |t|
      t.integer :accommodation_id
      t.integer :trip_id
    end
  end

  def self.down
    drop_table :accommodations_trips
  end
end
