class AddStatusLinesToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :status_line_2, :string
  end

  def self.down
    remove_column :trips, :status_line_2
  end
end
