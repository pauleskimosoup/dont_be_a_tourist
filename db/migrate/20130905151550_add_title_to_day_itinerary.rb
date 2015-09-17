class AddTitleToDayItinerary < ActiveRecord::Migration
  def self.up
    add_column :day_itineraries, :title, :string
    change_column :day_itineraries, :summary, :text
  end

  def self.down
    remove_column :day_itineraries, :title
    change_column :day_itineraries, :summary, :string
  end
end
