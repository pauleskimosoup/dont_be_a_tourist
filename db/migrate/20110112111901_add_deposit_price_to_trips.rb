class AddDepositPriceToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :deposit_price, :float
  end

  def self.down
    remove_column :trips, :deposit_price
  end
end
