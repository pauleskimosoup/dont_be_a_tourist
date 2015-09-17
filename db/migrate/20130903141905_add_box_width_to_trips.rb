class AddBoxWidthToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :box_width, :string
    Trip.all.each {|x| x.update_attribute(:box_width, "Standard") }
  end

  def self.down
    remove_column :trips, :box_width
  end
end
