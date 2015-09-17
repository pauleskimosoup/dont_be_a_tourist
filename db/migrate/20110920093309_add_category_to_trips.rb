class AddCategoryToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :category, :string
  end

  def self.down
    remove_column :trips, :category
  end
end
