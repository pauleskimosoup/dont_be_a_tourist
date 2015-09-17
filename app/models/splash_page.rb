class SplashPage < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable
  
  has_and_belongs_to_many :promo_codes

  validates_presence_of :title
  validates_uniqueness_of :url
  validates_format_of :url,
                      :with    => /^\w*$/i,
                      :message => "must only contain a-z 0-9 or _" 
  

  def self.empty?
    self.count == 0
  end

end
