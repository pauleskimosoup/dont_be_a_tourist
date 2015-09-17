class AddSavingsToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :saving_type, :string
    add_column :promo_codes, :saving_value, :float
    add_column :promo_codes, :saving_target, :string
  end

  def self.down
    remove_column :promo_codes, :saving_type
    remove_column :promo_codes, :saving_value
    remove_column :promo_codes, :saving_target
  end
end
