module TimeStampable

  attr_accessor :dont_time_stamp_me

  def self.included(base)
    base.send(:before_save, :time_stamp)
    base.send(:before_create, :created_time_stamp)
  end


  def time_stamp
    unless self.dont_time_stamp_me
      self.last_updated = Time.now.getgm
      admin = Admin.get_current
      if admin
        self.updated_by = admin.name
      else
        self.updated_by = "Unknown"
      end
    end
  end

  def created_time_stamp
    unless self.dont_time_stamp_me
      admin = Admin.get_current
      if admin
        self.created_by = admin.name
      else
        self.created_by = "Unknown"
      end
    end
  end
end
