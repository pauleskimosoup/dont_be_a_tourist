class SiteProfile < ActiveRecord::Base


  include TimeStampable

  before_save :time_stamp

  def SiteProfile.first
    SiteProfile.find(:all).first || SiteProfile.new
  end

end
