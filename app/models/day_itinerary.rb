class DayItinerary < ActiveRecord::Base

  has_and_belongs_to_many :activities, :uniq => true
  belongs_to :trip

  validates_presence_of :day, :title, :summary, :content, :trip_id
  validates_uniqueness_of :day, :scope => :trip_id, :message => "should only happen once per trip"

  def self.days
   ["1","2","3","4","5","6","7","8","9","10","11","12","13","14"]
  end

end
