class TripFlag < ActiveRecord::Base
  
  include Tp2Mixin
  include TimeStampable
  include Taggable
  
  belongs_to :trip
   
end
