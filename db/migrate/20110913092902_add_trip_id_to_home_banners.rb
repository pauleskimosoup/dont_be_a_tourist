class AddTripIdToHomeBanners < ActiveRecord::Migration
  def self.up
    add_column :home_banners, :trip_id, :integer
  end

  def self.down
    remove_column :home_banners, :trip_id
  end
end
