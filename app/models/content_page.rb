class ContentPage < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder

  def ContentPage.empty?
    ContentPage.find(:all).empty?
  end

  def ContentPage.find_by_url(controller, action)
    ContentPage.find(:first, :conditions => ["controller = ? and action = ?", controller, action])
  end

end
