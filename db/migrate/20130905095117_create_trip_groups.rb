class CreateTripGroups < ActiveRecord::Migration
  def self.up
    create_table :trip_groups do |t|
      t.string :name
      t.text :summary
      t.string :cached_slug
      t.integer :picture1_id
      t.boolean :display, :default => true

      t.timestamps
    end
    add_column :trips, :trip_group_id, :integer
  end

  def self.down
    drop_table :trip_groups
    remove_column :trips, :trip_group_id
  end
end
