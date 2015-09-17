class User < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  attr_accessor :password, :promo_code, :require_promo_code

  validates_presence_of :email, :phone, :first_name, :family_name, :nationality
  validates_uniqueness_of :email
  validates_confirmation_of :password, :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'address does not seem to be valid.'
  validates_length_of :password, :in => 3..20, :on => :create


  has_many :photos
  has_many :carts
  has_many :bookings
  has_and_belongs_to_many :promo_codes

  before_save :create_password
  before_save :copy_email_to_username
  after_save :clear_password
  after_create :add_to_mailing_list

  def never_booked_before?
    bookings.length == 0
  end

  def self.hear_about_us_options
    return [ "Word of mouth", "Poster", "Friend", "Facebook", "Presentation", "Search engine", "Flyer", "Viva la fiesta" ]
  end

  def self.hear_about_trips_from_options
    return [ 'None', 'Bradford', 'Huddersfield', 'Leeds', 'Sheffield', 'Anywhere' ]
  end

  def copy_email_to_username
    self.username = self.email
  end

  def surname
    self.family_name
  end

  def name
    "#{self.first_name} #{self.family_name}"
  end

  def stars
    s = ""
    for booking in self.bookings
      s += "*" unless booking == self.bookings.first
    end
    return s
  end

  def name_booked
    "#{name} #{stars}"
  end

  def create_password
    unless self.password == "" || self.password == nil
      self.hashed_password = User.hash_password(self.password)
    end
  end

  def clear_password
    self.password = nil
    self.password_confirmation = nil
  end

  def self.login(username, password)
    hashed_password = User.hash_password(password || "")
    user = find(:first, :conditions => ["username = ? and hashed_password = ?", username, hashed_password])
    return user
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

  def add_to_mailing_list
    begin
      require "uri"
      require "net/http"

      #logger.info "1"
      if self.newsletter? && self.hear_about_trips_from != "None"
        logger.info "Trips From"
        logger.info self.hear_about_trips_from
        if self.hear_about_trips_from == 'Bradford'
          my_hash = {'YMP3' => self.first_name,
                     'YMP4' => self.family_name,
                     'YMP0' => self.email,
                     'YMP2' => self.how_did_you_hear,
                     'CAT135' => '1',
                     'action' => 'subscribe'}
        elsif self.hear_about_trips_from == 'Huddersfield'
          my_hash = {'YMP3' => self.first_name,
                     'YMP4' => self.family_name,
                     'YMP0' => self.email,
                     'YMP2' => self.how_did_you_hear,
                     'CAT134' => '1',
                     'action' => 'subscribe'}
        elsif self.hear_about_trips_from == 'Leeds'
          my_hash = {'YMP3' => self.first_name,
                     'YMP4' => self.family_name,
                     'YMP0' => self.email,
                     'YMP2' => self.how_did_you_hear,
                     'CAT132' => '1',
                     'action' => 'subscribe'}
        elsif self.hear_about_trips_from == 'Sheffield'
          my_hash = {'YMP3' => self.first_name,
                     'YMP4' => self.family_name,
                     'YMP0' => self.email,
                     'YMP2' => self.how_did_you_hear,
                     'CAT133' => '1',
                     'action' => 'subscribe'}
        elsif self.hear_about_trips_from == 'Anywhere'
          my_hash = {'YMP3' => self.first_name,
                     'YMP4' => self.family_name,
                     'YMP0' => self.email,
                     'YMP2' => self.how_did_you_hear,
                     'CAT72' => '1',
                     'action' => 'subscribe'}
        end
        logger.info "Hash"
        logger.info my_hash.to_yaml
        logger.info "Query"
        logger.info my_hash.to_query
        string = "id=guqmswwgmgs&#{my_hash.to_query}"

        x = Net::HTTP.get(URI.parse("http://ymlp.com/subscribe.php?#{string}"))

        logger.info x.to_yaml
      end
    rescue Exception => e
      logger.info e.to_yaml
    end
  end
end
