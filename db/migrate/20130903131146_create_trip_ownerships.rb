class CreateTripOwnerships < ActiveRecord::Migration
  def self.up
    create_table :trip_ownerships do |t|
      t.integer :trip_id
      t.integer :university_id

      t.timestamps
    end
  end

  def self.down
    drop_table :trip_ownerships
  end
end
