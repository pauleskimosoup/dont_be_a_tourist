class AddDiscountCodeNameToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :discount_code_name, :string
  end

  def self.down
    remove_column :bookings, :discount_code_name
  end
end
