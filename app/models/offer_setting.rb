class OfferSetting < ActiveRecord::Base

  include Tp2Mixin
  
  validates_numericality_of :multiple_trips_count, :only_integer => true, :greater_than => 0, :less_than => 10
  validates_numericality_of :multiple_trips_percentage, :only_integer => true, :greater_than => 0, :less_than => 100

  def self.instance
    self.first || self.create!  
  end

end
