class BenefitBanner < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  validates_presence_of :title, :quote, :description
  validates_numericality_of :position

  named_scope :active, :conditions => ["display = 1"]

  def self.empty?
    self.count.zero?
  end

  def self.past_random(count)
    BenefitBanner.find(:all, :conditions => "display = 1 AND page = 'Past Trips'", :order => "position", :limit => count)
  end

  def self.univ_random(count)
    BenefitBanner.find(:all, :conditions => "display = 1 AND page = 'Universities'", :order => "RAND()", :limit => count)
  end

  def self.pages
    ["Past Trips", "Universities"]
  end

end
