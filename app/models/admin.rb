require "digest/sha1"


class Admin < ActiveRecord::Base

  attr_accessor :password, :password2
  attr_accessible :name, :password, :password2, :email

  validates_presence_of :name, :email
  validates_presence_of :password, :password2, :on => :create
  validates_uniqueness_of :name

  before_save :create_password
  after_save :clear_password

  include TimeStampable

  include Tp2Mixin

  has_and_belongs_to_many :features

  @@current = nil

  def Admin.tmedia_admin
    Admin.find_by_name("tmedia")
  end

  def Admin.current
    @@current
  end

  def Admin.current=(val)
    @@current = val
  end

  def Admin.get_current
    if self.current
      self.find(self.current)
    end
  end

  def validate
    unless (self.password == self.password2) or self.password == "" or not self.password
      errors.add(:password, "should be the same in both fields")
    end
  end

  def create_password
    if self.password and self.password != ""
      self.hashed_password = Admin.hash_password(self.password)
    end
  end

  def clear_password
    @password = nil
    @password2 = nil
  end

  def self.login(name, password)
    hashed_password = hash_password(password || "")
    find(:first,
          :conditions => ["name = ? and hashed_password = ?",
                                  name, hashed_password])
  end

  def try_to_login
    Admin.login(self.name, self.password)
  end

  def has_permission?(class_name)
    self.features.include?(Feature.all_feature) || self.features.include?(Feature.find_by_class_name(class_name)) || class_name == "LoginController"
  end

  def superadmin?
    self.has_permission?("all") or self.has_permission?("SettingsController")
  end

  private
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end
end
