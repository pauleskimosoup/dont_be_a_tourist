class Pickup < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable
  
  validates_presence_of :name, :location, :map_code
  has_many :pickup_dropoff_times
  has_many :trips, :through => :pickup_dropoff_times
    
  def self.empty?
    self.count.zero?
  end
  
  def self.find_by_pickup_dropoff_time(string)
    begin
      potentials = Pickup.all.collect { |pickup| pickup.name[1..5] == string[1..5] }
      return potential.first
    rescue
      return nil
    end
  end
  
end
