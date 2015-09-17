class CancelledBookingItem < ActiveRecord::Base

  belongs_to :trip
  
  include Tp2Mixin
  
  def pick_time
    result = pickup_dropoff.scan(/Pickup: (\d+[.,:;]?\d{0,2})/)
    if result.first && result.first.first
      return result.first.first
    else
      return "0"
    end
  end
   
end
