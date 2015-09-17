class BookingItem < ActiveRecord::Base

  has_and_belongs_to_many :products, :uniq => true
  
  belongs_to :booking
  belongs_to :trip
  before_destroy :update_pick_up_places
  
  include Tp2Mixin
  
  def pick_time
    result = pickup_dropoff.scan(/Pickup: (\d+[.,:;]?\d{0,2})/)
    if result.first && result.first.first
      return result.first.first
    else
      return "0"
    end
  end
  
  def update_pick_up_places
    unless pickup_dropoff_time_id.nil?
      begin
        pick_up_time = PickupDropoffTime.find(pickup_dropoff_time_id)
        pick_up_time.remove_from_places
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
   
end
