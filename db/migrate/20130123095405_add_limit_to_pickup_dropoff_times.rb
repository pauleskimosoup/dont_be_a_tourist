class AddLimitToPickupDropoffTimes < ActiveRecord::Migration
  def self.up
    add_column :pickup_dropoff_times, :limit, :integer
  end

  def self.down
    remove_column :pickup_dropoff_times, :limit
  end
end
