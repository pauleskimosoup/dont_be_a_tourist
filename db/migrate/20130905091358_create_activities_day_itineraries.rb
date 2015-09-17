class CreateActivitiesDayItineraries < ActiveRecord::Migration
  def self.up
    create_table :activities_day_itineraries, :id => false do |t|
      t.references :activity, :null => false
      t.references :day_itinerary, :null => false
    end

    add_index(:activities_day_itineraries, [:acitivity_id, :day_itinerary_id], :unique => true)
  end

  def self.down
    drop_table :activities_day_itineraries
  end
end
