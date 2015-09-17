class Reservation < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable
  
  def self.empty?
    self.count.zero?
  end

end
