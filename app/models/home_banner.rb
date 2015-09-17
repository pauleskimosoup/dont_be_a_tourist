class HomeBanner < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  belongs_to :trip

  has_attached_file :banner, :styles => { :home => "1920x734>"}
  validates_presence_of :name

  named_scope :active, :conditions => ["home_banners.display = 1 AND (link != 2 OR (link = 2 AND trips.start_date >= ?))", Date.today], :include => :trip
  named_scope :position, :order => "position"

  def self.empty?
    self.count.zero?
  end

  def self.links
    [
    ['Find a trip',1],
    ['Upcoming trip',2],
    ['Next big trip',3],
    ['Save money this semester',4]
    ]
  end

end
