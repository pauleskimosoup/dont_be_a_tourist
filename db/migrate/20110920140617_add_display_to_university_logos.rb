class AddDisplayToUniversityLogos < ActiveRecord::Migration
  def self.up
    add_column :university_logos, :display, :boolean, :default => true
  end

  def self.down
    remove_column :university_logos, :display
  end
end
