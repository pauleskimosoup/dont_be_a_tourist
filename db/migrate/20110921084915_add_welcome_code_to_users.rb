class AddWelcomeCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :welcome_code, :string
  end

  def self.down
    remove_column :users, :welcome_code
  end
end
