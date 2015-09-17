class BasketItem < ActiveRecord::Base
  
  attr_accessor :_destroy
  
  belongs_to :basket, :autosave => true
  belongs_to :trip
  has_and_belongs_to_many :products, :uniq => true
  
  include Tp2Mixin
  
  before_update :set_pickup_dropoff
  after_update :check_destroy
  
  def day_prices
    days = []
    day_on_this_trip_price = self.trip_total.to_f / self.trip.length
    self.trip.length.times do
      days << day_on_this_trip_price
    end
    return days.sort
  end
  
  def days
    trip.length
  end
  
  def set_pickup_dropoff
    pickup_dropoff_time = PickupDropoffTime.find(pickup_dropoff_time_id)
    self.pickup_dropoff = pickup_dropoff_time.name_pickup_time_dropoff_time
  end
  
  def check_destroy
    if _destroy == "1"
      self.destroy
    end
  end
  
  def trip_total
    total = 0
    total += trip.price(buyer_type)
    return total
  end
  
  def subtotal 
    total = 0
    total += trip_total
    if upgrade
      total += trip.upgrade_price
    end
    total += products_total
    return total
  end
  
  def subtotal_less_upgrade_extras
    total = 0
    total += trip_total
    return total
  end
  
  def deposit_subtotal
    if trip.deposit_price && trip.deposit_price > 0
      trip.deposit_price
    else
      subtotal
    end
  end
  
  def products_total
    ret = 0
    for product in products
      ret += product.price
    end
    return ret
  end
  
  def is_valid?
    (first_name? && last_name? && gender? && pickup_dropoff? && buyer_type? && trip_id) ? true : false
  end
  
  def paypal_name
    "#{first_name} #{last_name} - #{trip.name}"  
  end
  
  def convert_to_booking_item(booking)
    pickup_time = PickupDropoffTime.find(pickup_dropoff_time_id)
    pickup_time.add_to_places
    BookingItem.create!(:first_name => first_name, :last_name => last_name, :gender => gender, :pickup_dropoff => pickup_dropoff, :pickup_dropoff_time_id => pickup_dropoff_time_id, :buyer_type => buyer_type, :trip_id => trip_id, :upgrade => upgrade, :subtotal => subtotal, :booking_id => booking.id, :product_ids => product_ids)
  end

end
