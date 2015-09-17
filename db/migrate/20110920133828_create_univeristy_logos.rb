class CreateUniveristyLogos < ActiveRecord::Migration

  def self.up
    create_table "university_logos", :force => true do |t|
      t.string   "name"
      t.integer  "picture1_id",    :limit => 8
      t.integer  "picture2_id",    :limit => 8
      t.string   "url"
      t.datetime "last_updated"
      t.string   "updated_by"
      t.string   "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "university_logos"
  end
  
end
