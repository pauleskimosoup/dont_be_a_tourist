class CreateCancelledBookingItems < ActiveRecord::Migration
  def self.up
    create_table "cancelled_booking_items", :force => true do |t|
      t.integer  "booking_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "gender"
      t.text     "pickup_dropoff"
      t.string   "buyer_type"
      t.integer  "trip_id"
      t.boolean  "upgrade"
      t.float    "subtotal",       :default => 0.0
    end
  end

  def self.down
    drop_table "cancelled_booking_items"
  end
end
