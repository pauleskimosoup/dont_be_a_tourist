class PickupDropoffTime < ActiveRecord::Base
  
  belongs_to :trip
  belongs_to :pickup
  
  validates_numericality_of :limit, {:greater_than_or_equal_to => 0, :only_integer => true }
  
  def name_pickup_time_dropoff_time_with_places_left
    if (limit.nil? or (limit == 0) or (places_left > 10))
      name_pickup_time_dropoff_time
    else
      "#{pickup.name} - Pickup: #{pickup_time} / Dropoff: #{dropoff_time} (Only #{(places_left)} Places Left)"
    end
  end
  
  def name
    pickup.name 
  end
  
  def name_pickup_time_dropoff_time
    "#{pickup.name} - Pickup: #{pickup_time} / Dropoff: #{dropoff_time}"
  end
  
  def add_to_places
    unless limit == 0
      self.update_attribute(:places_cache, places_cache+1)
    end    
  end
  
  def remove_from_places
    unless limit == 0      
      self.update_attribute(:places_cache, places_cache-1)
    end
  end
  
  def places_left
    if (limit.nil? or limit == 0)
      100
    else
      limit - places_cache
    end
  end
    
end
