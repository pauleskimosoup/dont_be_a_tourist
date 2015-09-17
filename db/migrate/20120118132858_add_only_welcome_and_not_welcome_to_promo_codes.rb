class AddOnlyWelcomeAndNotWelcomeToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :only_welcome, :boolean, :default => false
    add_column :promo_codes, :not_welcome, :boolean, :default => false
  end

  def self.down
    remove_column :promo_codes, :not_welcome
    remove_column :promo_codes, :only_welcome
  end
end
