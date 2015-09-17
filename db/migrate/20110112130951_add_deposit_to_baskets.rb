class AddDepositToBaskets < ActiveRecord::Migration
  def self.up
    add_column :baskets, :deposit, :boolean
  end

  def self.down
    remove_column :baskets, :deposit
  end
end
