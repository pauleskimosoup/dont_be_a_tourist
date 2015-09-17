class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table "flags", :force => true do |t|
      t.string   "country_code"
      t.integer  "position"
      t.string     "name"
      t.boolean  "display"
      t.datetime "last_updated"
      t.string   "updated_by"
      t.string   "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "flags"
  end
end
