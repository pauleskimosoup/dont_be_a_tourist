class AddHomepageTextAndHomepageToPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :homepage_text, :text
    add_column :promo_codes, :homepage, :boolean
  end

  def self.down
    remove_column :promo_codes, :homepage
    remove_column :promo_codes, :homepage_text
  end
end
