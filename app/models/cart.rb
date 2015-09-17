# encoding: UTF-8
class Cart < ActiveRecord::Base

  has_many :trip_instances, :dependent => :destroy
  belongs_to :user
  has_one :payment_notification

  include Tp2Mixin

  def self.convert_to_bookings
    would_be_bookings = Cart.find(:all, :conditions => {:payment_recieved => 1})
    for cart in would_be_bookings

      if cart.payment_type && cart.payment_type.include?("paypal")
        booking_type = "paypal"
      elsif cart.payment_type && cart.payment_type.include?("offline payment")
        booking_type = "cash"
      else
        booking_type = nil
      end

      if cart.payment_recieved
        booking_status = "paid"
      else
        booking_status = "pending"
      end

      if !cart.payment_recieved
        outstanding_balance = cart.total
      else
        outstanding_balance = 0
      end

      booking = Booking.create!(:user_id => cart.user_id,
                                         :total => cart.total,
                                         :discount_total => 0,
                                         :notes => cart.notes,
                                         :booking_type => cart.payment_type,
                                         :booking_status => booking_status,
                                         :basket_id => nil,
                                         :outstanding_balance => outstanding_balance)
      for trip_instance in cart.trip_instances
        booking_item = BookingItem.create!(:booking_id => booking.id,
                                           :first_name => trip_instance.first_name,
                                           :last_name => trip_instance.last_name,
                                           :gender => trip_instance.sex,
                                           :pickup_dropoff => trip_instance.pickup_dropoff,
                                           :buyer_type => "Student",
                                           :trip_id => trip_instance.trip_id,
                                           :upgrade => trip_instance.upgrade,
                                           :subtotal => trip_instance.total)
        for product in trip_instance.products
          booking_item.products << product
        end
      end
    end
    return would_be_bookings.length
  end

  def not_full?
    trip_instances_trips = trip_instances.collect{|ti| ti.trip}
    for trip in trip_instances_trips
      same_destinations = trip_instances_trips.select{|t| t == trip}
      if trip.places < same_destinations.length
        return false
      end
    end
    return true
  end

  def paypal_url(return_url, notify_url, demo)
    first_name = self.user.name.split(' ')[0] || nil
    last_name = self.user.name.split(' ')[1] || nil
    business = 'nevil@dontbeatourist.co.uk'

    values = {
      :business => business,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :invoice => "es#{id}",
      :no_shipping => 1,
      :ship_to_country_code => 'GB',
      :currency_code => 'GBP',
      :country => 'GB',
      :first_name => first_name,
      :last_name => last_name,
      :address_override => 0,
    }

    trip_instances.each_with_index do |trip_instance, index|
      values.merge!({
        "amount_#{index+1}" => sprintf('%.2f', ((trip_instance.total + (trip_instance.total*0.035)))).to_f,
        "item_name_#{index+1}" => "#{trip_instance.name} - #{trip_instance.trip.name} Booking",
        "item_number_#{index+1}" => trip_instance.id,
        "quantity_#{index+1}" => 1
      })
    end
    if demo
      "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
    else
      "https://www.paypal.com/cgi-bin/webscr?" + values.to_query
    end
  end

  def total
    total = 0
    for trip_instance in self.trip_instances
      total += trip_instance.total
  end
    total + extras
  end

  def total_plus_paypal
    total + (total*0.035)
  end

  def just_paypal
    (total*0.035)
  end

  def totalf
    "&pound;#{sprintf('%.2f', self.total)}"
  end

  def total_plus_offlinef
    "&pound;#{sprintf('%.2f', self.total+3.50)}"
  end


  def convert_to_booking
    self.update_attributes(:payment_type => 'offline payment', :payment_recieved => 0, :purchased_at => Time.now, :extras => 0)
  end

  def generate_invoice
    require 'rubygems'
    require 'prawn'
    require "prawn/core"
    require "prawn/layout"
    require 'prawn/format'
    dir = "#{RAILS_ROOT}/public/documents/invoices"
    unless File.directory? dir
      Dir.mkdir dir
    end

    cart = self

    Prawn::Document.generate("#{RAILS_ROOT}/public/documents/invoices/#{id}.pdf") do

      address_image = "#{RAILS_ROOT}/public/images/admin/invoice_address.png"
      image(open(address_image), :position => :right, :vposition => -40, :scale => 0.45)

      text "Cash Invoice", :align => :left, :size => 25

      table([[cart.user.name, "Invoice number:", "#{cart.id}"],
             ["", "Invoice date:", "#{cart.purchased_at.strftime("%d/%m/%Y")}"]],
            :border_style => :underline_header,
            :font_size => 14,
            :column_widths => {0 => 340, 1 => 120, 2 => 80},
            :align => {0 => :left, 1 => :left, 2 => :right})

      move_down 20

      data = []
      for trip_instance in cart.trip_instances
        description = trip_instance.description
        for product in trip_instance.products
          description += " - " + product.name
        end
        description += trip_instance.upgrade ? " - with upgrade":""
        data << [description, "£#{sprintf('%.2f', trip_instance.total.to_f)}"]
      end
      data << ["Cash Transaction Fee at 3.5%", "£#{sprintf('%.2f', cart.just_paypal.to_f)}"]

      table([["",""]],
            :headers => ["Description", "Total"],
            :border_style => :underline_header,
            :font_size => 12,
            :column_widths => {0 => 470, 1 => 70},
            :align => {0 => :left, 1 => :right})

      table(data,
            :border_style => :underline_header,
            :font_size => 10,
            :column_widths => {0 => 470, 1 => 70},
            :align => {0 => :left, 1 => :right})

      move_down 10

      table([["Invoice Total including VAT @ 17.5%","£#{sprintf('%.2f', cart.total_plus_paypal.to_f)}"]],
            :border_style => :underline_header,
            :column_widths => {0 => 470, 1 => 70},
            :align => {0 => :left, 1 => :right})

      start_new_page

      move_down 40

      text "Making cash deposits into our bank account:", :size => 12, :style => :bold

      move_down 10

      text "&bull; When at the bank please complete the paying-in slip with the following details:<br/>"

      move_down 5

      indent 15 do
        text "Date: <b>Today’s date</b> (e.g. 27/08/09)", :size => 10
        text "Bank: <b>HSBC Bank</b>", :size => 10
        text "Account Holding Branch: <b>Leeds City Branch</b>", :size => 10
        text "Customer's Name: <b>Don't be a tourist Ltd</b>", :size => 10
        text "Name and Address of person paying in (if not customer): <br/><b>Write: 'Please include reference number ________' (and enter your Cash Invoice number)", :size => 10
        text "Sorting Code Number: <b>40-27-15</b>", :size => 10
        text "Account Number: <b>84096274</b>", :size => 10
        text "Finally, write the amount you are paying in.", :size => 10
      end

      move_down 5

      text "&bull; If you have an account with HSBC use your card to access the paying-in machine. If you don’t have an HSBC account, ask a member of staff for help."

      move_down 5

      text "&bull; Keep the receipt from the machine or the cashier as proof of payment."

      move_down 5

      text "&bull; We check our bank account daily. When we see your payment, we will email you your Confirmation Invoice immediately."

      move_down 20

      text "All the above goods and services are subject to our terms and conditions, a copy of which is available on our website or on request.", :size => 10

      footer [margin_box.left, margin_box.bottom] do
        table([["Don’t be a tourist Limited", "Company number: 5913320", "Registered in England at 20b Main Street Leeds LS15 4JQ"]],
              :border_style => :underline_header,
              :column_widths => {0 => 140, 1 => 180, 2 => 220},
              :font_size => 8,
              :align => {0 => :left, 1 => :center, 2 => :right},
              :vpositon => :bottom)
      end
    end
  end

end
