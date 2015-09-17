class AddCachedSlugToUniversities < ActiveRecord::Migration
  def self.up
    add_column :universities, :cached_slug, :string
  end

  def self.down
    remove_column :universities, :cached_slug
  end
end
