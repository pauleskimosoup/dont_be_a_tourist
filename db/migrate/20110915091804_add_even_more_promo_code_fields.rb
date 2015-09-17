class AddEvenMorePromoCodeFields < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :booking_condition_day, :boolean, :default => false
    add_column :promo_codes, :booking_condition_overnight, :boolean, :default => false
    add_column :promo_codes, :booking_condition_multinight, :boolean, :default => false
  end

  def self.down
    remove_column :promo_codes, :booking_condition_day
    remove_column :promo_codes, :booking_condition_overnight
    remove_column :promo_codes, :booking_condition_multinight
  end
end
