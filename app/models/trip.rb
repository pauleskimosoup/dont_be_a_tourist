class Trip < ActiveRecord::Base

  has_many :trip_flags, :dependent => :destroy
  accepts_nested_attributes_for :trip_flags, :reject_if => lambda{|a| a[:country_code].blank? }, :allow_destroy => true

  include ActionView::Helpers::NumberHelper
  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  attr_accessor :delete_document, :delete_photo_1, :delete_photo_2, :delete_photo_3, :delete_photo_4

  belongs_to :promoted_trip, :class_name => "Trip"
  belongs_to :trip_group
  has_many :photos
  has_many :reviews
  has_many :videos
  has_many :trip_instances
  has_many :rooms
  has_and_belongs_to_many :destinations
  has_and_belongs_to_many :accommodations
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :products
  has_many :pickup_dropoff_times, :dependent => :destroy
  accepts_nested_attributes_for :pickup_dropoff_times, :reject_if => lambda{|a| a[:pickup_id].blank? }, :allow_destroy => true
  has_many :pickups, :through => :pickup_dropoff_times
  has_many :trip_ownerships, :dependent => :destroy
  has_many :universities, :through => :trip_ownerships

  has_many :day_itineraries
  has_many :booking_items
  has_many :basket_items
  has_many :cancelled_booking_items
  has_many :day_itineraries, :order => :day, :dependent => :destroy

  has_attached_file :document
  has_attached_file :photo_1
  has_attached_file :photo_2
  has_attached_file :photo_3
  has_attached_file :photo_4

  validates_presence_of :name, :start_date, :end_date, :student_price, :adult_price, :upgrade_price
  validates_numericality_of :student_price, :greater_than => 0
  validates_numericality_of :adult_price, :greater_than => 0
  validates_presence_of :summary, :on => :update
  validates_presence_of :itinerary, :on => :update
  validates_numericality_of :group_booking_count, :greater_than => 0, :only_integer => true
  validates_numericality_of :bookable_places, :greater_than => 0, :only_integer => true, :if => Proc.new{|x| x.bookable_places? }
  validates_numericality_of :group_booking_percentage, :greater_than => 0, :only_integer => true
  validates_presence_of :bookable_places, :if => Proc.new{|x| x.no_rooms? }
  validates_numericality_of :deposit_price, :greater_than_or_equal_to => 0

  validate :trip_has_destination, :on => :create

  named_scope :active, :conditions => ["display = 1"]
  named_scope :past, :conditions => ["end_date < ?", Date.today]
  named_scope :future, :conditions => ["start_date >= ?", Date.today], :order => "start_date"
  named_scope :on_list, lambda{ { :conditions => ["display=? AND start_date>=? AND highlight = ?", true, Date.today, true], :order => 'start_date asc' } }

  before_save :check_delete_document, :check_delete_photos, :calculate_length
  after_validation :set_video_embed_width_and_height

  def set_video_embed_width_and_height
    self.youtube_embed_code.gsub!(/width="\d*"/, 'width="900"').gsub!(/height="\d*"/, 'height="450"') unless youtube_embed_code.blank?
  end

  def self.categories
    ["Semester 1", "Christmas & New Year", "Semester 2", "Easter", "Summer"]
  end

  def check_delete_document
    if delete_document == "1"
      self.document = nil
    end
  end

  def check_delete_photos
    if delete_photo_1 == "1"
      self.photo_1.destroy
    end
    if delete_photo_2 == "1"
      self.photo_2.destroy
    end
    if delete_photo_3 == "1"
      self.photo_3.destroy
    end
    if delete_photo_4 == "1"
      self.photo_4.destroy
    end
  end

  def calculate_length
    self.length = ((self.end_date - self.start_date) + 1).to_i
  end

  def trip_has_destination
    errors.add('Destination', 'required') if self.destinations.length < 1
  end

  def before_create
    self.display = 0
  end

  def upgrade?
    upgrade_price > 0 ? true : false
  end

  def self.upcoming(limit = 2)
    self.find(:all, :conditions => ['display=true AND start_date >= ?', Date.today], :order => 'start_date', :limit => limit)
  end

  def picture
    if self.has_picture1?
      self.picture1
    else
      nil
    end
  end

  def comment
    comments = []
    self.destinations.each do |destination|
      destination.trips.each do |trip|
        trip.reviews.each{|c| comments << c}
      end
    end
    comments.sort_by{rand}.first
  end

  def pickup_time(pickup_id)
    pickup_time = self.pickup_dropoff_times.select{|x| x.pickup_id == pickup_id}.collect{|x| x.pickup_time}
  end

  def dropoff_time(pickup_id)
    dropoff_time = self.pickup_dropoff_times.select{|x| x.pickup_id == pickup_id}.collect{|x| x.dropoff_time}
  end

  def pickup_ids=(pickup_ids)
    # collect the ones which need to be destroyed
    self.pickup_dropoff_times.each do |pickup_dropoff_time|
      pickup_dropoff_time.destroy unless pickup_ids.include? pickup_dropoff_time.pickup_id
    end
    pickup_ids.each do |pickup_id|
      self.pickup_dropoff_times.create(:pickup_id => pickup_id) unless self.pickup_dropoff_times.any? { |d| d.pickup_id == pickup_id }
    end
  end

  def self.empty?
    self.count.zero?
  end

  def self.next
    Trip.find(:first, :conditions => ["display=1 AND start_date >= ?", Date.today], :order=>"start_date ASC")
  end

  def default_itinerary
    default_itinerary = self.destination.itinerary
    100.times do |number|
      default_itinerary.gsub!("DAY#{number}", (self.start_date + number).to_s)
    end
    default_itinerary
  end

  def length
    ((self.end_date - self.start_date) + 1).to_i
  end

  def day_trip?
    length == 1
  end

  def overnight_trip?
    length == 2
  end

  def multinight_trip?
    length > 2
  end


  def dates
    if start_date != end_date
      "#{self.start_date.strftime('%a %d %b %Y')} - #{self.end_date.strftime('%a %d %b %Y')}"
    else
      start_date.strftime('%a %d %b %Y')
    end
  end

  def length_dates
    if start_date != end_date
      "#{self.length} Days, #{self.start_date.strftime('%a %d %b %Y')} - #{self.end_date.strftime('%a %d %b %Y')}"
    else
      "1 Day, #{start_date.strftime('%a %d %b %Y')}"
    end

  end

  def pricef
    "&pound;#{sprintf('%.2f', self.price)}"
  end

  def upgrade_pricef
    "&pound;#{sprintf('%.2f', self.upgrade_price)}"
  end

  def destination_name_dates
    "#{self.name} - #{self.dates}"
  end

  def name_dates
    "#{self.name} - #{self.dates}"
  end

  def valid_basket_items
    self.basket_items.select{|x| x.basket && x.basket.expiry_time && x.basket.expiry_time > Time.now}
  end

  def rooms_configurations
      #require 'system_timer'
      require 'timeout'
      working_configurations = []
      begin

      Timeout::timeout(10) do
      #SystemTimer.timeout(10.seconds) do

        # add existing bookings
        males = booking_items.select{|x| x.gender == "Male"}.length
        females = booking_items.select{|x| x.gender == "Female"}.length

        total = males + females

        rooms = self.rooms.collect{|x| x.places}
        original_rooms = rooms.dup
        total_places = rooms.sum
        men_combs = []

        for i in 1..[rooms.length, males].min
          men_combs += rooms.combination(i).to_a.select{|x| (x.reduce(:+) >= males) && (females <= (total_places - x.reduce(:+)) )}.uniq
        end

        # for each of the possible male combinations
        for men_comb in men_combs

          # see what rooms are left
          rooms_left = original_rooms.dup
          for men_room in men_comb
            rooms_left.delete_at(rooms_left.index(men_room))
          end

          women_combs = []
          for i in 1..[rooms_left.length, females].min
            women_combs += rooms_left.combination(i).to_a.select{|x| (x.reduce(:+) >= females)}.uniq
          end

          for women_comb in women_combs

            comb_out = []

            # for each of the mens rooms in this combination
            for men_room in men_comb
              # make male room
              comb_out << "#{men_room}m"
            end

            # for each of the womens rooms in this combination
            for women_room in women_comb
              # make female room
              comb_out << "#{women_room}f"
            end

            # make a note of empty rooms
            rooms_left = original_rooms.dup
            for room in comb_out
              rooms_left.delete_at(rooms_left.index(room.to_s.gsub(/\D/, "").to_i))
            end

            for neut_room in rooms_left
              comb_out << neut_room
            end
            working_configurations << comb_out
            return working_configurations if self.rooms.length > 15 && working_configurations.length >= 3
          end

        end
      end
      rescue Exception => e
        logger.info e.message
        #logger.info e.backtrace.inspect
      end
      return working_configurations
  end

  def working_configurations
    wc = []
    for number in (0..places)
      m = number
      f = places-number
      wc << [m,f] if bookable?(m,f)
    end
    return wc
  end

  def total_places
    total = 0
    room_places = rooms.map{|x| x.places}.sum || 0
    if bookable_places != nil
      if bookable_places <= room_places || no_rooms?
        total = bookable_places
      else
        total = room_places
      end
    else
      total = rooms.map{|x| x.places}.sum
    end
    return total
  end

  def places
    ret = total_places
    ret -= booking_items.length
    ret -= valid_basket_items.length
    return ret
  end

  def sold_out?
    places < 1
  end

  def price(buyer_type)
    if buyer_type == "Student"
      if early_early_bird?
        new_price = student_price - early_bird_1_amount_off
      elsif early_bird?
        new_price = student_price - early_bird_2_amount_off
      else
        new_price = student_price - (10.0 * (student_price/100.00))
      end
    else
      if early_early_bird?
        new_price = adult_price - early_bird_1_amount_off
      elsif early_bird?
        new_price = adult_price - early_bird_2_amount_off
      else
        new_price = adult_price - (10.0 * (student_price/100.00))
      end
    end
  end

  def new_price(buyer_type)
    if buyer_type == "Student"
      student_price
    else
      adult_price
    end
  end

  def pretty_student_price
    new_price = nil

    if early_early_bird?
      new_price = student_price - early_bird_1_amount_off
    elsif early_bird?
      new_price = student_price - early_bird_2_amount_off
    else
      new_price = student_price - (10.0 * (student_price/100.00))
    end

    if new_price
      "<strong>Students:</strong> <del>#{number_to_currency student_price, :unit => "&pound;"}</del> <span class='price'>#{number_to_currency new_price, :unit => "&pound;"}</span>"
    else
      "<strong>Students:</strong> <span class='price'>#{number_to_currency student_price, :unit => "&pound;"}</span>"
    end
  end

  def pretty_adult_price
    new_price = nil

    if early_early_bird?
      new_price = adult_price - early_bird_1_amount_off
    elsif early_bird?
      new_price = adult_price - early_bird_2_amount_off
    else
      new_price = adult_price - (10.0 * (adult_price/100.00))
    end

    if new_price
      "<strong>Adults:</strong> <del>#{number_to_currency adult_price, :unit => "&pound;"}</del> <span class='price'>#{number_to_currency new_price, :unit => "&pound;"}</span>"
    else
      "<strong>Adults:</strong> <span class='price'>#{number_to_currency adult_price, :unit => "&pound;"}</span>"
    end
  end

  def format_upgrade_description
    if upgrade_description?
      upgrade_description
    else
      "Upgrade"
    end
  end

  def bookable?(males, females)
    total = males + females

    # check that the places requested dont go over the bookable places
    if total > places
      return false
    end

    # if there are no rooms just do the simple, genderless check
    if no_rooms && total <= places
      return true
    end

     # add existing bookings
    males += booking_items.select{|x| x.gender == "Male"}.length
    females += booking_items.select{|x| x.gender == "Female"}.length

    # add existing baskets
    males += valid_basket_items.select{|x| x.gender == "Male"}.length
    females += valid_basket_items.select{|x| x.gender == "Female"}.length

    rooms = self.rooms.collect{|x| x.places}
    places_on_trip = rooms.sum

    total_people = males + females
    places_left = places_on_trip - total_people

    if (rooms.size > 20) and (places_left > rooms.sort.first)
      return true
    end



    men_combs = []

    for i in 1..[rooms.length, males].min
      #men_combs += rooms.combination(i).to_a.select{|x| (x.reduce(:+) >= males) && (females <= (total_places - x.reduce(:+)) )}.uniq
      men_combs += rooms.combination(i).to_a.select{|x| (x.reduce(:+) >= males) && (females <= (places_on_trip - x.reduce(:+)) )}.uniq
    end

    if males == 0
      return (females < total_places) ? true : false
    else
      return men_combs.length > 0 ? true : false
    end

  end

  def early_early_bird?

    if early_bird_1_date.present? and (Date.today <= early_bird_1_date) and early_bird_1_amount_off.present?
      true
    else
      false
    end

    #if welcome_trip?
    #  false
    #elsif day_trip?  && Date.today + (26) < start_date
    #  true
    #elsif (multinight_trip?|| overnight_trip?) && Date.today + (54) < start_date
    #  true
    #else
    #  false
    #end
  end

  def early_early_bird_date
    early_bird_1_date
    #if day_trip?
    #  start_date - (26)
    #else
    #  start_date - (54)
    #end
  end

  def early_bird?
    if early_bird_2_date.present? and (Date.today <= early_bird_2_date) and early_bird_2_amount_off.present?
      true
    else
      false
    end
    #if welcome_trip?
    #  false
    #elsif day_trip? && Date.today + (12) < start_date
    #  true
    #elsif (multinight_trip? || overnight_trip?) && Date.today + (26) < start_date
    #  true
    #else
    #  false
    #end
  end

  def early_bird_date
    early_bird_2_date
    #if day_trip?
    #  start_date - (12)
    #else
    #  start_date - (26)
    #end
  end

  def week_before_early_early_bird
    if early_early_bird? and Date.today <= early_early_bird_date && Date.today >= early_early_bird_date-7
      early_early_bird_date - Date.today
    else
      nil
    end
  end

  def week_before_early_bird
    if early_bird? and Date.today <= early_bird_date && Date.today >= early_bird_date-7
      early_bird_date - Date.today
    else
      nil
    end
  end

  def rcc

    #require 'system_timer'
    require 'timeout'
    working_configurations = []
    Timeout::timeout(10) do
    #SystemTimer.timeout(60.seconds) do

      # add existing bookings
      males = booking_items.select{|x| x.gender == "Male"}.length
      females = booking_items.select{|x| x.gender == "Female"}.length

      total = males + females

      rooms = self.rooms.collect{|x| x.places}
      original_rooms = rooms.dup
      total_places = rooms.sum
      men_combs = []

      for i in 1..[rooms.length, males].min
        men_combs += rooms.combination(i).to_a.select{|x| (x.reduce(:+) >= males) && (females <= (total_places - x.reduce(:+)) )}.uniq
      end

      # for each of the possible male combinations
      for men_comb in men_combs

        # see what rooms are left
        rooms_left = original_rooms.dup
        for men_room in men_comb
          rooms_left.delete_at(rooms_left.index(men_room))
        end

        women_combs = []
        for i in 1..[rooms_left.length, females].min
          women_combs += rooms_left.combination(i).to_a.select{|x| (x.reduce(:+) >= females)}.uniq
        end

        for women_comb in women_combs

          comb_out = []

          # for each of the mens rooms in this combination
          for men_room in men_comb
            # make male room
            comb_out << "#{men_room}m"
          end

          # for each of the womens rooms in this combination
          for women_room in women_comb
            # make female room
            comb_out << "#{women_room}f"
          end

          # make a note of empty rooms
          rooms_left = original_rooms.dup
          for room in comb_out
            rooms_left.delete_at(rooms_left.index(room.to_s.gsub(/\D/, "").to_i))
          end

          for neut_room in rooms_left
            comb_out << neut_room
          end
          working_configurations << comb_out
          return working_configurations if self.rooms.length > 15 && working_configurations.length >= 3
        end


        return working_configurations.length
      end
    end
  end

end
