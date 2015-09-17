class <%= class_name %> < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  validates_presence_of :date

  def self.empty?
    self.count == 0
  end

  def self.find_latest_n(n)
    self.displayable.find(:all,
          :order => 'date desc',
          :limit => n)
  end


  def self.find_recent(n="10")
    news_by_n = self.find_latest_n(n)
    news_by_date = self.displayable.find(:all, :order => "date desc",
                                            :conditions => "date_sub(curdate(), interval 30 day) <= date")
    if news_by_n.length > news_by_date.length
      news_by_n
    else
      news_by_date
    end
  end

  def self.all_from_date(month, year)
    if not year
      year = Date.today.year
    end
    self.displayable.find(:all,
                :order => 'date desc',
                :conditions => ["month(date) = ? and year(date) = ?", month, year])
  end


end
