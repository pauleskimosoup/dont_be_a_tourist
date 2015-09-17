class AddAttachmentsPhoto1Photo2Photo3AndPhoto4ToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :photo_1_file_name, :string
    add_column :trips, :photo_1_content_type, :string
    add_column :trips, :photo_1_file_size, :integer
    add_column :trips, :photo_1_updated_at, :datetime
    add_column :trips, :photo_2_file_name, :string
    add_column :trips, :photo_2_content_type, :string
    add_column :trips, :photo_2_file_size, :integer
    add_column :trips, :photo_2_updated_at, :datetime
    add_column :trips, :photo_3_file_name, :string
    add_column :trips, :photo_3_content_type, :string
    add_column :trips, :photo_3_file_size, :integer
    add_column :trips, :photo_3_updated_at, :datetime
    add_column :trips, :photo_4_file_name, :string
    add_column :trips, :photo_4_content_type, :string
    add_column :trips, :photo_4_file_size, :integer
    add_column :trips, :photo_4_updated_at, :datetime
    add_column :trips, :photo_1_alt, :string
    add_column :trips, :photo_2_alt, :string
    add_column :trips, :photo_3_alt, :string
    add_column :trips, :photo_4_alt, :string
  end

  def self.down
    remove_column :trips, :photo_1_file_name
    remove_column :trips, :photo_1_content_type
    remove_column :trips, :photo_1_file_size
    remove_column :trips, :photo_1_updated_at
    remove_column :trips, :photo_2_file_name
    remove_column :trips, :photo_2_content_type
    remove_column :trips, :photo_2_file_size
    remove_column :trips, :photo_2_updated_at
    remove_column :trips, :photo_3_file_name
    remove_column :trips, :photo_3_content_type
    remove_column :trips, :photo_3_file_size
    remove_column :trips, :photo_3_updated_at
    remove_column :trips, :photo_4_file_name
    remove_column :trips, :photo_4_content_type
    remove_column :trips, :photo_4_file_size
    remove_column :trips, :photo_4_updated_at
    remove_column :trips, :photo_1_alt
    remove_column :trips, :photo_2_alt
    remove_column :trips, :photo_3_alt
    remove_column :trips, :photo_4_alt
  end
end
