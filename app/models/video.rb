class Video < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  belongs_to :trip
  belongs_to :destination
  belongs_to :user

  named_scope :active, :conditions => ["display = ? AND video_code IS NOT NULL", true]
  named_scope :random, :order => "RAND()"
  named_scope :trip_id, lambda{ |trip_id| { :conditions => ["trip_id = ?", trip_id] } }
  named_scope :destination_id, lambda{ |destination_id| { :conditions => ["destination_id = ?", destination_id] } }
  named_scope :destination_ids, lambda{ |destination_ids| { :conditions => ["destination_id IN (?)", destination_ids] } }

  def self.empty?
    self.count.zero?
  end

  def self.select_default(params)
    if params[:subject_type] == 'destination'
      return Destination.find(params[:subject_id]).trips.select{|x| x.display == true && x.start_date < Date.today}.first.id
    elsif params[:subject_type] == 'trip'
      return Trip.find(params[:subject_id]).id
    else
     return nil
    end
  end

  def self.random(count = 10, options = {})
    options[:destination_id] ||= nil
    options[:trip_id] ||= nil
    videos = self.find(:all, :conditions => 'display = 1')
    if options[:destination_id]
      videos = videos.select{|x| x.trip.destination_ids.include?(options[:destination_id])}
    end
    if options[:trip_id]
      videos = videos.select{|x| x.trip.name == (Trip.find(options[:trip_id]).name)}
    end
    videos = videos.sort_by{rand}
    return videos[0..(count-1)]
  end

  def picture
    string = self.video_code
    code = string.split('?v=')[1]
    "http://img.youtube.com/vi/#{code}/default.jpg"
  end

end
