class AddHighlightToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :highlight, :boolean, :default => false

    
  end

  def self.down
    remove_column :trips, :highlight
  end
end
