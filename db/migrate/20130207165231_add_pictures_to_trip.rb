class AddPicturesToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :picture2_id, :integer
    add_column :trips, :picture3_id, :integer
    add_column :trips, :picture4_id, :integer
  end

  def self.down
    remove_column :trips, :picture4_id
    remove_column :trips, :picture3_id
    remove_column :trips, :picture2_id
  end
end
