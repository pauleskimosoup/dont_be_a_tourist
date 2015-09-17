class AddPromotionalFieldsToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :youtube_embed_code, :text
    add_column :trips, :promotional_phrase, :text
    add_column :trips, :promoted_trip_id, :integer
    add_index :trips, :promoted_trip_id
  end

  def self.down
    remove_column :trips, :promoted_trip_id
    remove_column :trips, :promotional_phrase
    remove_column :trips, :youtube_embed_code
  end
end
