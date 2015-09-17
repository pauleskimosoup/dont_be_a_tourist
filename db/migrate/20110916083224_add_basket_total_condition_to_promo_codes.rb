class AddBasketTotalConditionToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :basket_total_condition, :integer
  end

  def self.down
    remove_column :promo_codes, :basket_total_condition
  end
end
