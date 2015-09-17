class AddPickupDropoffTimeIdToBookingItems < ActiveRecord::Migration
  def self.up
    add_column :booking_items, :pickup_dropoff_time_id, :integer
  end

  def self.down
    remove_column :booking_items, :pickup_dropoff_time_id
  end
end
