class AddRatingToTripGroup < ActiveRecord::Migration
  def self.up
    add_column :trip_groups, :rating, :string, :default => "0 Stars"
  end

  def self.down
    remove_column :trip_groups, :rating
  end
end
