class AddPickupDropoffTimeIdToBasketItems < ActiveRecord::Migration
  def self.up
    add_column :basket_items, :pickup_dropoff_time_id, :integer
  end

  def self.down
    remove_column :basket_items, :pickup_dropoff_time_id
  end
end
