class TripInstance < ActiveRecord::Base

  include Tp2Mixin

  belongs_to :cart
  belongs_to :trip
  has_and_belongs_to_many :products

  validates_presence_of :cart_id, :trip_id, :first_name, :last_name, :sex, :pickup_dropoff
  validates_length_of :first_name, :maximum => 50
  validates_length_of :last_name, :maximum => 50

   HUMANIZED_ATTRIBUTES = {
    :last_name => "Family name"
  }

  before_destroy :update_places

  def update_places
    self.trip.update_attribute(:places, self.trip.places + 1)
  end

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  attr_accessor :skip

  def skip_validatation
    skip
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def total
    if self.trip == nil
      return 0
    end
    total = self.trip.price("Student")
    if self.upgrade
      total += self.trip.upgrade_price
    end
    for product in self.products
      total += product.price
    end
    total
  end

  def totalf
    "&pound;#{sprintf('%.2f', self.total)}"
  end

  def pickup
    begin
      pickup_name = self.pickup_dropoff.split(' - ')[0]
      return Pickup.find_by_name(pickup_name)
    rescue
      return nil
    end
  end

  def description
    "#{name} - #{trip.destination_name_dates}"
  end

end
