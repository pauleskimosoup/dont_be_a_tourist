class AddAltAttrToHomeBanner < ActiveRecord::Migration
  def self.up
    add_column :home_banners, :image_alt, :string
  end

  def self.down
    remove_column :home_banners, :image_alt
  end
end
