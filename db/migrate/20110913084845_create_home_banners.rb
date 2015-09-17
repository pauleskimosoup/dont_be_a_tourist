class CreateHomeBanners < ActiveRecord::Migration
  def self.up
    create_table :home_banners do |t|
      t.string :name
      t.text :summary
      t.integer :picture1_id
      t.integer :link
      t.integer :position

      t.boolean :display, :default => true
      t.string :created_by
      t.string :updated_by
      t.datetime :last_updated      
      t.datetime :updated_at
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :home_banners
  end
end
