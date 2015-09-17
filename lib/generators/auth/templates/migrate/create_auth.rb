class Create<%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
      t.string :username
      t.string :hashed_password
      t.string :email
      t.string :name
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :postcode
      t.string :phone
      t.datetime "last_updated"
      t.string   "updated_by"
      t.string   "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
