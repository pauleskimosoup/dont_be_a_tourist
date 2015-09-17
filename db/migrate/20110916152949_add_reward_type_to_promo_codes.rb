class AddRewardTypeToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :reward_type, :string
  end

  def self.down
    remove_column :promo_codes, :reward_type
  end
end
