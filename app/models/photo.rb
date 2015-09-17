class Photo < ActiveRecord::Base

  belongs_to :user
  belongs_to :trip
  belongs_to :destination

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable
  
  named_scope :active, :conditions => ["display = ? AND picture1_id IS NOT NULL", true]
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

end
