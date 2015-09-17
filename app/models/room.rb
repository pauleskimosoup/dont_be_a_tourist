class Room < ActiveRecord::Base

  include Tp2Mixin
  
  belongs_to :trip
  
  validates_numericality_of :places, :only_integer => true
  
  attr_accessor :current_places

end
