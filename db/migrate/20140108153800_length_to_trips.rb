class LengthToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :length, :integer
  end

  def self.down
    remove_column :trips, :length
  end
end
