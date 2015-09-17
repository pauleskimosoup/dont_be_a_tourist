class AddSloganToUniversityLogoAndRenameToUniversity < ActiveRecord::Migration
  def self.up
    rename_table :university_logos, :universities
    add_column :universities, :slogan, :string
  end

  def self.down
    remove_column :universities, :slogan
    rename_table :universities, :university_logos
  end
end
