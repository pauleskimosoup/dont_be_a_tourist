# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150917101216) do

  create_table "accommodations", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accommodations_trips", :id => false, :force => true do |t|
    t.integer "accommodation_id"
    t.integer "trip_id"
  end

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.integer  "picture1_id",    :limit => 8
    t.integer  "picture2_id",    :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "destination_id", :limit => 8
  end

  create_table "activities_day_itineraries", :id => false, :force => true do |t|
    t.integer "activity_id",      :null => false
    t.integer "day_itinerary_id", :null => false
  end

  create_table "activities_trips", :id => false, :force => true do |t|
    t.integer "activity_id", :limit => 8
    t.integer "trip_id",     :limit => 8
  end

  create_table "admins", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "hashed_password",           :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
  end

  create_table "admins_features", :id => false, :force => true do |t|
    t.integer "admin_id",   :limit => 8
    t.integer "feature_id", :limit => 8
  end

  create_table "backups", :force => true do |t|
    t.string   "name"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename"
  end

  create_table "basket_items", :force => true do |t|
    t.integer  "basket_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.text     "pickup_dropoff"
    t.string   "buyer_type",             :default => "Student"
    t.integer  "trip_id"
    t.boolean  "upgrade",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pickup_dropoff_time_id"
  end

  create_table "basket_items_products", :id => false, :force => true do |t|
    t.integer "basket_item_id", :limit => 8
    t.integer "product_id",     :limit => 8
  end

  create_table "baskets", :force => true do |t|
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "promo_code_id"
    t.datetime "expiry_time"
    t.boolean  "deposit"
  end

  create_table "benefit_banners", :force => true do |t|
    t.string   "title"
    t.string   "quote"
    t.text     "description"
    t.integer  "picture1_id"
    t.string   "page"
    t.boolean  "display"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     :default => 0
  end

  create_table "booking_items", :force => true do |t|
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
    t.float    "subtotal",               :default => 0.0
    t.integer  "pickup_dropoff_time_id"
  end

  create_table "booking_items_products", :id => false, :force => true do |t|
    t.integer "booking_item_id"
    t.integer "product_id"
  end

  create_table "bookings", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total",               :default => 0.0
    t.float    "discount_total",      :default => 0.0
    t.text     "notes"
    t.string   "booking_type"
    t.string   "booking_status"
    t.integer  "basket_id"
    t.float    "outstanding_balance", :default => 0.0
    t.string   "discount_code_name"
    t.float    "booking_amount"
  end

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

  create_table "carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "purchased_at"
    t.boolean  "payment_recieved"
    t.string   "payment_type"
    t.text     "notes"
    t.integer  "user_id",          :limit => 8
    t.float    "extras",                        :default => 0.0
  end

  create_table "content_pages", :force => true do |t|
    t.string   "name"
    t.text     "button_text"
    t.text     "body"
    t.integer  "picture1_id",  :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "action"
    t.text     "controller"
  end

  create_table "day_itineraries", :force => true do |t|
    t.integer  "trip_id"
    t.string   "day"
    t.text     "summary"
    t.text     "content"
    t.text     "highlights"
    t.boolean  "display",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "destinations", :force => true do |t|
    t.string   "name"
    t.integer  "picture1_id",  :limit => 8
    t.integer  "picture2_id",  :limit => 8
    t.integer  "picture3_id",  :limit => 8
    t.integer  "picture4_id",  :limit => 8
    t.text     "summary"
    t.text     "description"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "itinerary"
    t.integer  "picture5_id",  :limit => 8
  end

  create_table "destinations_trips", :id => false, :force => true do |t|
    t.integer "destination_id"
    t.integer "trip_id"
  end

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.text     "description"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", :force => true do |t|
    t.string "name"
    t.string "controller"
  end

  create_table "flags", :force => true do |t|
    t.string   "country_code"
    t.integer  "position"
    t.string   "name"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "home_banners", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.integer  "picture1_id"
    t.string   "link"
    t.integer  "position"
    t.boolean  "display",             :default => true
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "last_updated"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "trip_id"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.string   "image_alt"
  end

  create_table "linked_promo_codes", :id => false, :force => true do |t|
    t.integer "main_promo_code_id",   :limit => 8
    t.integer "linked_promo_code_id", :limit => 8
  end

  create_table "offer_settings", :force => true do |t|
    t.integer  "multiple_trips_count",      :default => 3
    t.integer  "multiple_trips_percentage", :default => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "cart_id",        :limit => 8
    t.string   "status"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  create_table "photos", :force => true do |t|
    t.string   "name"
    t.integer  "picture1_id",    :limit => 8
    t.integer  "user_id",        :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trip_id",        :limit => 8
    t.integer  "destination_id", :limit => 8
  end

  create_table "pickup_dropoff_times", :force => true do |t|
    t.integer "pickup_id",    :limit => 8
    t.integer "trip_id",      :limit => 8
    t.string  "pickup_time"
    t.string  "dropoff_time"
    t.integer "limit"
    t.integer "places_cache",              :default => 0
  end

  create_table "pickups", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.text     "directions"
    t.text     "map_code"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.text     "image_alt"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.float    "price"
    t.integer  "picture1_id",  :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products_promo_codes", :id => false, :force => true do |t|
    t.integer "product_id",    :limit => 8
    t.integer "promo_code_id", :limit => 8
  end

  create_table "products_trip_instances", :id => false, :force => true do |t|
    t.integer "product_id",       :limit => 8
    t.integer "trip_instance_id", :limit => 8
  end

  create_table "products_trips", :id => false, :force => true do |t|
    t.integer "product_id", :limit => 8
    t.integer "trip_id",    :limit => 8
  end

  create_table "promo_codes", :force => true do |t|
    t.text     "description"
    t.string   "code"
    t.integer  "percentage_discount_off_order"
    t.integer  "percentage_discount_off_trip"
    t.boolean  "free_upgrade"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "amount_discount_off_order"
    t.integer  "activation_type",                     :default => 1
    t.integer  "alert_level"
    t.integer  "days_condition"
    t.integer  "people_condition"
    t.integer  "early_condition"
    t.boolean  "splash_page"
    t.string   "url"
    t.text     "main_content"
    t.boolean  "form"
    t.integer  "days_discount"
    t.integer  "percentage_discount_off_next_person"
    t.string   "trip_type"
    t.boolean  "booking_condition_day",               :default => false
    t.boolean  "booking_condition_overnight",         :default => false
    t.boolean  "booking_condition_multinight",        :default => false
    t.boolean  "first_booking"
    t.integer  "basket_total_condition"
    t.string   "reward_type"
    t.string   "saving_type"
    t.float    "saving_value"
    t.string   "saving_target"
    t.text     "homepage_text"
    t.boolean  "homepage"
    t.boolean  "only_welcome",                        :default => false
    t.boolean  "not_welcome",                         :default => false
    t.boolean  "uses_up_bookings",                    :default => true
  end

  create_table "promo_codes_splash_pages", :id => false, :force => true do |t|
    t.integer "promo_code_id",  :limit => 8
    t.integer "splash_page_id", :limit => 8
  end

  create_table "promo_codes_users", :id => false, :force => true do |t|
    t.integer "promo_code_id", :limit => 8
    t.integer "user_id",       :limit => 8
  end

  create_table "reservations", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "telephone"
    t.string   "trip"
    t.string   "male"
    t.string   "female"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "rating",         :limit => 8
    t.integer  "user_id",        :limit => 8
    t.integer  "trip_id",        :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.integer  "destination_id"
  end

  create_table "rooms", :force => true do |t|
    t.integer  "trip_id"
    t.integer  "places",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_profiles", :force => true do |t|
    t.string   "address"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "last_updated"
    t.text     "company_address"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "splash_pages", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "summary"
    t.text     "main_content"
    t.integer  "picture1_id",  :limit => 8
    t.integer  "picture2_id",  :limit => 8
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "body"
    t.integer  "picture1_id",  :limit => 8
    t.date     "date"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id",   :limit => 8
    t.integer "tag_id",        :limit => 8
    t.string  "taggable_type"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "trip_flags", :force => true do |t|
    t.string   "country_code"
    t.integer  "trip_id"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trip_groups", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.string   "cached_slug"
    t.integer  "picture1_id"
    t.boolean  "display",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rating",      :default => "0 Stars"
  end

  create_table "trip_instances", :force => true do |t|
    t.integer "cart_id",        :limit => 8
    t.integer "trip_id",        :limit => 8
    t.string  "sex"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "pickup_dropoff"
    t.boolean "upgrade",                     :default => false
  end

  create_table "trip_ownerships", :force => true do |t|
    t.integer  "trip_id"
    t.integer  "university_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trips", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "itinerary"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "upgrade_price"
    t.text     "highlights"
    t.text     "whats_included"
    t.text     "more_info"
    t.text     "tagline"
    t.string   "facebook_url"
    t.integer  "picture1_id"
    t.text     "status"
    t.float    "student_price",            :default => 0.0
    t.float    "adult_price",              :default => 0.0
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.string   "upgrade_description"
    t.integer  "group_booking_count",      :default => 5
    t.integer  "group_booking_percentage", :default => 10
    t.integer  "bookable_places"
    t.boolean  "no_rooms"
    t.string   "status_line_2"
    t.float    "deposit_price"
    t.string   "category"
    t.text     "room_notes"
    t.boolean  "welcome_trip",             :default => false
    t.integer  "picture2_id"
    t.integer  "picture3_id"
    t.integer  "picture4_id"
    t.boolean  "highlight",                :default => false
    t.string   "box_width"
    t.date     "early_bird_1_date"
    t.float    "early_bird_1_amount_off",  :default => 0.0
    t.date     "early_bird_2_date"
    t.float    "early_bird_2_amount_off",  :default => 0.0
    t.integer  "trip_group_id"
    t.string   "photo_1_file_name"
    t.string   "photo_1_content_type"
    t.integer  "photo_1_file_size"
    t.datetime "photo_1_updated_at"
    t.string   "photo_2_file_name"
    t.string   "photo_2_content_type"
    t.integer  "photo_2_file_size"
    t.datetime "photo_2_updated_at"
    t.string   "photo_3_file_name"
    t.string   "photo_3_content_type"
    t.integer  "photo_3_file_size"
    t.datetime "photo_3_updated_at"
    t.string   "photo_4_file_name"
    t.string   "photo_4_content_type"
    t.integer  "photo_4_file_size"
    t.datetime "photo_4_updated_at"
    t.string   "photo_1_alt"
    t.string   "photo_2_alt"
    t.string   "photo_3_alt"
    t.string   "photo_4_alt"
    t.integer  "length"
    t.text     "youtube_embed_code"
    t.text     "promotional_phrase"
    t.integer  "promoted_trip_id"
  end

  add_index "trips", ["promoted_trip_id"], :name => "index_trips_on_promoted_trip_id"

  create_table "universities", :force => true do |t|
    t.string   "name"
    t.integer  "picture1_id",  :limit => 8
    t.integer  "picture2_id",  :limit => 8
    t.string   "url"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display",                   :default => true
    t.string   "slogan"
    t.string   "cached_slug"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "hashed_password"
    t.string   "email"
    t.string   "phone"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "newsletter"
    t.text     "address"
    t.text     "billing_address"
    t.string   "how_did_you_hear"
    t.string   "university"
    t.string   "hear_about_trips_from"
    t.string   "first_name"
    t.string   "family_name"
    t.boolean  "over_eighteen"
    t.string   "how_long_in_uk"
    t.string   "welcome_code"
    t.string   "nationality"
  end

  create_table "videos", :force => true do |t|
    t.string   "name"
    t.integer  "trip_id",        :limit => 8
    t.integer  "user_id",        :limit => 8
    t.text     "video_code"
    t.boolean  "display"
    t.datetime "last_updated"
    t.string   "updated_by"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "destination_id"
  end

end
