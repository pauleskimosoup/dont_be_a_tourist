class CreateSplashPages < ActiveRecord::Migration
  def self.up
    create_table "splash_pages", :force => true do |t|
      t.string   "title"
      t.string   "url"
      t.text     "summary"
      t.text     "main_content"
      t.integer  "picture1_id",    :limit => 8
      t.integer  "picture2_id",    :limit => 8
      t.boolean  "display"
      t.datetime "last_updated"
      t.string   "updated_by"
      t.string   "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end  
    
    create_table "promo_codes_splash_pages", :id => false, :force => true do |t|
      t.integer "promo_code_id", :limit => 8
      t.integer "splash_page_id",     :limit => 8
    end
    
    create_table "promo_codes_users", :id => false, :force => true do |t|
      t.integer "promo_code_id", :limit => 8
      t.integer "user_id",     :limit => 8
    end

  end

  def self.down
    drop_table "splash_pages"
    drop_table "promo_codes_splash_pages"
    drop_table "promo_codes_users"
  end
end
