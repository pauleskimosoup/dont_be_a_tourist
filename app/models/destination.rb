class Destination < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  has_and_belongs_to_many :trips
  has_many :activities
  has_many :photos
  has_many :videos
  has_many :reviews

  validates_presence_of :name, :summary, :description

  named_scope :active, :conditions => ["display = 1"]

  def self.empty?
    self.count.zero?
  end

  def random_picture
    unless self.has_picture1? || self.has_picture2? || self.has_picture3? || self.has_picture4?
      return nil
    end
    pictures = []
    pictures << self.picture1 << self.picture2 << self.picture3 << self.picture4
    picture = nil
    while picture == nil
      picture = pictures[rand(pictures.length)]
    end
    return picture
  end

  def photos
    photos = []
    for trip in trips
      photos += trip.photos
    end
    return photos.compact
  end

  def videos
    videos = []
    for trip in videos
      videos += trip.videos
    end
    return videos.compact
  end

  def reviews
    reviews = []
    for trip in trips
      reviews += trip.reviews
    end
    return reviews
  end

  def upcoming_trips
    self.trips.select{|x| x.start_date > Date.today}
  end

  def self.random(count)
    Destination.find(:all, :conditions => 'display=1', :limit => count)
  end

  def map
    if self.has_picture5?
      self.picture5
    else
      nil
    end
  end

end
