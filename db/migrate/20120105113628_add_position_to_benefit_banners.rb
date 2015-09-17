class AddPositionToBenefitBanners < ActiveRecord::Migration
	
  def self.up
  	add_column :benefit_banners, :position, :integer, :default => 0
  end
	
  def self.down
  	remove_column :benefit_banners, :position
  end
  
end
