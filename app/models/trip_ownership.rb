class TripOwnership < ActiveRecord::Base

  belongs_to :trip
  belongs_to :university

end
