class AddEarlyBird1And2ToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :early_bird_1_date, :date
    add_column :trips, :early_bird_1_amount_off, :float, :default => 0.0
    add_column :trips, :early_bird_2_date, :date
    add_column :trips, :early_bird_2_amount_off, :float, :default => 0.0
  end

  def self.down
    remove_column :trips, :early_bird_2_amount_off
    remove_column :trips, :early_bird_2_date
    remove_column :trips, :early_bird_1_amount_off
    remove_column :trips, :early_bird_1_date
  end
end
