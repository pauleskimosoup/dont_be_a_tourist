class LinkedPromoCodes < ActiveRecord::Migration
  def self.up
    create_table "linked_promo_codes", :id => false, :force => true do |t|
      t.integer "main_promo_code_id", :limit => 8
      t.integer "linked_promo_code_id",     :limit => 8
    end
  end

  def self.down
    drop_table "linked_promo_codes"
  end
end
