class AddHowLongInUkToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :how_long_in_uk, :string
  end

  def self.down
    remove_column :users, :how_long_in_uk
  end
end
