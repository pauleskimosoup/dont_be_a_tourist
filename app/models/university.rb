class University < ActiveRecord::Base
  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  has_friendly_id :url, :use_slug => true
  has_many :trip_ownerships
  has_many :trips, :through => :trip_ownerships

  def self.empty?
    self.count.zero?
  end

  validates_presence_of :name, :url
  validates_uniqueness_of :name, :url

  named_scope :active, :conditions => ["display = true AND picture1_id IS NOT NULL"]

end
