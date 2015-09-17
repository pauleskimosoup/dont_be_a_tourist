class <%= class_name %> < ActiveRecord::Base
  
  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable
  
  attr_accessor :password

  validates_presence_of :name, :username, :email
  validates_uniqueness_of :username
  validates_confirmation_of :password, :email  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'address does not seem to be valid.'
  validates_length_of :username, :in => 3..20
  validates_length_of :password, :in => 3..20, :unless => 'password == ""', :on => :create

  before_save :create_password
  after_save :clear_password
  
  def first_name
    self.name.split[0] ||= ""
  end
  
  def surname
    self.name.split[1] ||= ""
  end

  def create_password
    unless self.password == "" || self.password == nil
      self.hashed_password = <%= class_name %>.hash_password(self.password)
    end
  end

  def clear_password
    self.password = nil
    self.password_confirmation = nil
  end
  
  def self.login(username, password)
    hashed_password = <%= class_name %>.hash_password(password || "")
    <%= singular_name %> = find(:first, :conditions => ["username = ? and hashed_password = ?", username, hashed_password])
    return <%= singular_name %>
  end
  
  def address
    output = Array.new
    output << self.address_1
    output << self.address_2
    output << self.address_3
    output << self.postcode
    return output
  end

  def reset_password
    new_password = random_password(6)
    self.update_attribute(:password, new_password)
    return new_password
  end

  private
  require 'digest/sha1'

  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end

  def random_password(length)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    random_password = ''
    1.upto(length) { |i| random_password << chars[rand(chars.size-1)] }
    return random_password
  end

end
