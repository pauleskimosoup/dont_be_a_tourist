class Activity < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  has_and_belongs_to_many :trips
  belongs_to :destination
  has_and_belongs_to_many :day_itineraries, :uniq => true

  validates_uniqueness_of :name

  def self.empty?
    self.count.zero?
  end

end
