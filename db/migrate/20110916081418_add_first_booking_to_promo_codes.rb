class AddFirstBookingToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :first_booking, :boolean
  end

  def self.down
    remove_column :promo_codes, :first_booking
  end
end
