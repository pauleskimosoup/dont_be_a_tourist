class AddDepositAmountToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :booking_amount, :float
  end

  def self.down
    remove_column :bookings, :booking_amount
  end
end
