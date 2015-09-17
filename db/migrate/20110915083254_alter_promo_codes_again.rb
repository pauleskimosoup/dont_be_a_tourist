class AlterPromoCodesAgain < ActiveRecord::Migration
  def self.up
    remove_column :promo_codes, :trip_id
    remove_column :promo_codes, :overnight_trips
    remove_column :promo_codes, :day_trips
    add_column :promo_codes, :trip_type, :string
  end

  def self.down
    add_column :promo_codes, :trip_id, :integer
    add_column :promo_codes, :overnight_trips, :boolean, :default => true
    add_column :promo_codes, :day_trips, :boolean, :default => true
    remove_column :promo_codes, :trip_type
  end
end
