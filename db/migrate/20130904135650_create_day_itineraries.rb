class CreateDayItineraries < ActiveRecord::Migration
  def self.up
    create_table :day_itineraries do |t|
      t.integer :trip_id
      t.string :day
      t.string :summary
      t.text :content
      t.text :highlights
      t.boolean :display, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :day_itineraries
  end
end
