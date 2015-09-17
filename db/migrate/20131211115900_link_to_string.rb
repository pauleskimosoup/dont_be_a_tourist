class LinkToString < ActiveRecord::Migration
  def self.up
    change_column :home_banners, :link, :string
  end

  def self.down
    change_column :home_banners, :link, :integer
  end
end
