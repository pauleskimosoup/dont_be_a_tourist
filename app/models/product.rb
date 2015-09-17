class Product < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  has_and_belongs_to_many :trips
  has_and_belongs_to_many :trip_instances
  
  validates_uniqueness_of :name
  validates_presence_of :price, :name, :summary#, :description
  validates_numericality_of :price, :greater_than => 0
  
  def self.empty?
    self.count.zero?
  end
  
  def pricef
    "&pound;#{sprintf('%.2f', self.price)}"
  end

end
