class AddOverEighteenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :over_eighteen, :boolean
  end

  def self.down
    remove_column :users, :over_eighteen
  end
end
