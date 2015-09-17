class AlterPromoCodes < ActiveRecord::Migration
  def self.up
    add_column :promo_codes, :start_date, :date
    add_column :promo_codes, :end_date, :date
    add_column :promo_codes, :amount_discount_off_order, :float
    add_column :promo_codes, :overnight_trips, :boolean, :default => true
    add_column :promo_codes, :day_trips, :boolean, :default => true
    add_column :promo_codes, :activation_type, :integer, :default => 1
    add_column :promo_codes, :alert_level, :integer
    add_column :promo_codes, :days_condition, :integer
    add_column :promo_codes, :people_condition, :integer
    add_column :promo_codes, :early_condition, :integer
    add_column :promo_codes, :splash_page, :boolean
    add_column :promo_codes, :url, :string
    add_column :promo_codes, :main_content, :text
    add_column :promo_codes, :form, :boolean
    add_column :promo_codes, :days_discount, :integer
    add_column :promo_codes, :percentage_discount_off_next_person, :integer
  end

  def self.down
    remove_column :promo_codes, :start_date
    remove_column :promo_codes, :end_date
    remove_column :promo_codes, :amount_discount_off_order
    remove_column :promo_codes, :overnight_trips
    remove_column :promo_codes, :day_trips
    remove_column :promo_codes, :activation_type
    remove_column :promo_codes, :alert_level
    remove_column :promo_codes, :days_condition
    remove_column :promo_codes, :people_condition
    remove_column :promo_codes, :early_condition
    remove_column :promo_codes, :splash_page
    remove_column :promo_codes, :url
    remove_column :promo_codes, :main_content
    remove_column :promo_codes, :form
    add_column :promo_codes, :days_discount
    add_column :promo_codes, :percentage_discount_off_next_person
  end
end
