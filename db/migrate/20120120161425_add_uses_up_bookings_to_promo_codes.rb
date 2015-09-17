class AddUsesUpBookingsToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :uses_up_bookings, :boolean, :default => true
  end

  def self.down
    remove_column :promo_codes, :uses_up_bookings
  end
end
