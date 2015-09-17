# encoding: UTF-8
class Basket < ActiveRecord::Base

  BOOKING_FEE = 2.5

  belongs_to :user
  has_many :basket_items, :dependent => :destroy
  belongs_to :promo_code
  accepts_nested_attributes_for :basket_items, :allow_destroy => true

  include Tp2Mixin

  before_save :update_expiry_time

  def update_expiry_time
    self.expiry_time = Time.now + 60 * 15
  end

  def day_prices
    days = []
    for basket_item in basket_items
      day_on_this_trip_price = basket_item.trip_total.to_f / basket_item.trip.length
      basket_item.trip.length.times do
        days << day_on_this_trip_price
      end
    end
    return days.sort
  end

  def depositable?
    for trip in trips
      if trip.deposit_price && trip.deposit_price > 0
        return true
      end
    end
    return false
  end

  def deposit?
    super && depositable?
  end

  def possible_promo_codes
    ppcs = []
    for pc in PromoCode.in_date.automatic
      ppcs << pc
    end
    if user
      for pc in user.promo_codes
        ppcs << pc
      end
    end
    ppcs << promo_code if promo_code
    return ppcs
  end

  def best_promo_code_name_and_saving
    ppcs = possible_promo_codes.collect{|x| x.name_and_saving_for(self) }.sort_by{|x| x.last}
    logger.info 'POSSIBLE CODES AND SAVINGS SUMMARY'
    for ppc in ppcs
      logger.info "£#{ppc.last} - #{ppc.first}"
    end
    return ppcs.last
  end

  # examine the basket items and return false if any of them aren't valid (using the basket items is_valid? method)
  # also check that the trips arent full
  def all_basket_items_valid?
    for basket_item in basket_items
      return false unless basket_item.is_valid?
    end
    for trip in trips
      return false if !trip.bookable?(0, 0)
    end
    return true
  end

  def male_bookings(trip=nil)
    bookings = basket_items.select{|x| x.gender == "Male"}
    if trip == nil
      return bookings.length
    else
      return bookings.select{|x| x.trip == trip}.length
    end
  end

  def female_bookings(trip=nil)
    bookings = basket_items.select{|x| x.gender == "Female"}
    if trip == nil
      return bookings.length
    else
      return bookings.select{|x| x.trip == trip}.length
    end
  end

  def trips
    basket_items.collect{|x| x.trip}.uniq
  end

  def total_days
    ret = 0
    for basket_item in basket_items
      ret += basket_item.trip.length
    end
    return ret
  end

  # examine the basket items and return the sum total
  def total
    ret = 0
    ret += basket_items_total
    ret -= discount_total
    ret += self.booking_fee
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def total_without_discount
    ret = 0
    ret += basket_items_total
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def total_without_discount_less_upgrade_extras
    ret = 0
    ret += basket_items_total_less_upgrade_extras
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def total_before_booking_fee
    ret = 0
    ret += basket_items_total
    ret -= discount_total
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def booking_fee
    ret = 0
    ret += total_before_booking_fee * (BOOKING_FEE / 100.to_f)
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def only_deposit
    ret = 0
    for basket_item in basket_items
      ret += basket_item.trip.deposit_price if basket_item.trip.deposit_price > 0
    end
    return ret
  end

  def deposit_total
    ret = 0
    for basket_item in basket_items
      ret += basket_item.deposit_subtotal
    end
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def basket_items_total
    ret = 0
    for basket_item in basket_items
      ret += basket_item.subtotal
    end
    return ret
  end

  def basket_items_total_less_upgrade_extras
    ret = 0
    for basket_item in basket_items
      ret += basket_item.subtotal_less_upgrade_extras
    end
    return ret
  end

  def promo_discount
    pc = best_promo_code_name_and_saving
    unless pc.blank?
      pc.last
    else
      0
    end
  end

  def enough_pick_up_places?
    pick_up_points = basket_items.map{|x| x.pickup_dropoff_time_id}.uniq

    for pick_up_point in pick_up_points
      count = basket_items.count(:conditions => "pickup_dropoff_time_id = #{pick_up_point}")
      point_selected = PickupDropoffTime.find(pick_up_point)
      unless point_selected.limit.nil? or (point_selected.limit == 0)
        numbers_left = (point_selected.limit - (point_selected.places_cache + count))
        if numbers_left < 0
          return false
        end
      end
    end


    return true
  end

  #def promo_discount
  #  ret = 0
  #
  #  if promo_code
  #
  #    if promo_code.percentage_discount_off_order
  #      ret += basket_items_total.to_f * (promo_code.percentage_discount_off_order.to_f/100.to_f)
  #    end
  #
  #    if promo_code.percentage_discount_off_trip && promo_code.trip
  #      trip_items = basket_items.select{|x| x.trip == promo_code.trip}
  #      for item in trip_items
  #        ret += item.subtotal.to_f * (promo_code.percentage_discount_off_trip.to_f/100.to_f)
  #      end
  #    end
  #
  #    if promo_code.free_upgrade?
  #      for item in basket_items
  #        if item.upgrade?
  #          ret += item.trip.upgrade_price
  #        end
  #      end
  #    end
  #
  #    if promo_code.products.length > 0
  #      for item in basket_items
  #        # sort so that the cheapest of the free items in the basket will have the discount applies to it.
  #        for product in item.products.sort_by{|x| x.price}
  #          if promo_code.products.include?(product)
  #            ret += product.price
  #            break
  #          end
  #        end
  #      end
  #    end
  #
  #  end
  #
  #  return ret
  #end

  def outstanding_balance
    total - deposit_total
  end

  def discount_total
    ret = 0
    ret += promo_discount
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def paypal_url(return_url, notify_url)
    business = 'nevil@dontbeatourist.co.uk'
    #business = 'seller_1284561622_biz@eskimosoup.co.uk'

    values = {
      :business => business,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :invoice => "dbat#{id}",
      :no_shipping => 1,
      :ship_to_country_code => 'GB',
      :currency_code => 'GBP',
      :country => 'GB',
      :address_override => 0,
    }



    unless deposit
      # calculate the total discount and apply it to the cart
      discount = 0
      discount += discount_total
      if discount > 0
        values = values.merge(:discount_amount_cart => discount)
      end
    end

    count = 0

    basket_items.each_with_index do |basket_item, index|
      count = index + 1
      if deposit?
        basket_item_price = basket_item.deposit_subtotal
      else
        basket_item_price = basket_item.subtotal
      end
      basket_item_price =
      values = values.merge({
        "amount_#{count}" => sprintf('%.2f', basket_item_price),
        "item_name_#{count}" => basket_item.paypal_name,
        "item_number_#{count}" => basket_item.id,
        "quantity_#{count}" => 1
      })
    end

    unless deposit?
      count += 1
      values = values.merge({
        "amount_#{count}" => sprintf('%.2f', booking_fee),
        "item_name_#{count}" => "Booking Fee",
        "item_number_#{count}" => "0",
        "quantity_#{count}" => 1
      })
    end

    "https://www.paypal.com/cgi-bin/webscr?" + values.to_query
    #"https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end

  def convert_to_booking(options={})
    if Booking.find(:all, :conditions => {:basket_id => self.id}).length > 0
      return Booking.find(:all, :conditions => {:basket_id => self.id}).first
    end

    if best_promo_code_name_and_saving
      discount_code_name = best_promo_code_name_and_saving.first
    else
      discount_code_name = ""
    end

    booking_amount = (deposit?) ? deposit_total : 0

    booking = Booking.new(:total => total,
      :discount_total => discount_total,
      :user_id => user.id,
      :basket_id => self.id,
      :booking_type => options[:booking_type],
      :booking_status => options[:booking_status],
      :notes => notes,
      :discount_code_name => discount_code_name,
      :booking_amount => booking_amount
      )
    # if this in an admin booking caculcate if the full amount has been paid
    # or if not the remaining balance
    if options[:booking_type].include?("admin")
      booking.outstanding_balance = self.total - options[:amount].to_f
      if booking.outstanding_balance > 0
        booking.booking_status = "part paid"
      elsif booking.outstanding_balance == 0
        booking.booking_status = "paid"
      end
    elsif options[:booking_type] == "cash"
      booking.outstanding_balance = booking.total
    elsif options[:booking_type == "free"]
      booking.outstanding_balance = 0
    elsif options[:booking_type] == "paypal"
      if deposit
        booking.outstanding_balance = outstanding_balance
      else
        booking.outstanding_balance = 0
      end
    end

    booking.save!
    for basket_item in basket_items
      basket_item.convert_to_booking_item(booking)
    end
    if booking.booking_type == "cash"
      Mailer.deliver_prelim_booking_info(booking.id)
      Mailer.deliver_prelim_booking_notice(booking.id)
    end
    if booking.booking_status == "paid"
      Mailer.deliver_booking_info(booking.id)
      Mailer.deliver_booking_notice(booking.id)
    end

    # remove the promo code from the users account since they have used it
    if best_promo_code_name_and_saving
      for id in best_promo_code_name_and_saving[1]
        user.update_attribute(:promo_code_ids, user.promo_code_ids.reject{|x| x == id}) if user.promo_code_ids.include?(id)
      end
    end

    return booking
  end

end
