class Flag < ActiveRecord::Base

  include Tp2Mixin
  
  validates_presence_of :name, :country_code
    
end
