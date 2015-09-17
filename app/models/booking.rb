# encoding: UTF-8
class Booking < ActiveRecord::Base

  BOOKING_FEE = 2.5

  include Tp2Mixin

  belongs_to :basket
  belongs_to :user
  has_many :booking_items, :dependent => :destroy
  has_one :payment_notification

  named_scope :cash, :conditions => {:booking_type => "cash"}
  named_scope :pending, :conditions => {:booking_status => "pending"}

  def trips
    booking_items.collect{|x| x.trip}.uniq
  end

  def cancel!
    for booking_item in booking_items
      cbi = CancelledBookingItem.new
      cbi.booking_id = booking_item.booking_id
      cbi.first_name = booking_item.first_name
      cbi.last_name = booking_item.last_name
      cbi.gender = booking_item.gender
      cbi.pickup_dropoff = booking_item.pickup_dropoff
      cbi.buyer_type = booking_item.buyer_type
      cbi.trip_id = booking_item.trip_id
      cbi.upgrade = booking_item.upgrade
      cbi.subtotal = booking_item.subtotal
      cbi.save
    end
    destroy
  end

  def paid
    ret = 0
    ret += (total - outstanding_balance)
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def booking_fee
    ret = 0
    ret += total / 1.025 * 0.025
    ret = sprintf('%.2f', ret).to_f
    return ret
  end

  def paypal_url(return_url, notify_url)
    business = 'nevil@dontbeatourist.co.uk'
    #business = 'seller_1284561622_biz@eskimosoup.co.uk'

    values = {
      :business => business,
      :cmd => '_xclick',
      :item_name => "Don't Be A Tourist Order (ref: #{id})",
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :invoice => id,
      :no_shipping => 1,
      :ship_to_country_code => 'GB',
      :currency_code => 'GBP',
      :country => 'GB',
      :address_override => 0,
      :amount => outstanding_balance
    }
    return "https://www.paypal.com/cgi-bin/webscr?" + values.to_query
    #return "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end

  def self.send_reminder_emails
    logger.info "Cash Payment Reminders..."
    puts "Cash Payment Reminders..."
    for booking in self.cash.pending
      if booking.created_at.to_date == Date.yesterday
        logger.info "Mailing #{booking.user.email} (Booking Ref: #{booking.id})"
        puts "Mailing #{booking.user.email} (Booking Ref: #{booking.id})"
        Mailer.deliver_cash_payment_reminder(booking)
      end
    end
    logger.info "Deposit Payment Reminders..."
    puts "Deposit Payment Reminders..."
    for booking in self.find(:all, :conditions => ["outstanding_balance > 0"])
      if booking.created_at.to_date == (Date.today-42)
        logger.info "Mailing #{booking.user.email} (Booking Ref: #{booking.id})"
        puts "Mailing #{booking.user.email} (Booking Ref: #{booking.id})"
        Mailer.deliver_payment_reminder(booking)
      end
    end
    return "finished"
  end

  def payment_deadline
    if booking_status.include?("pending")
      deadline = created_at.tomorrow.tomorrow
      while deadline.day == 6 || deadline.day == 7
        deadline = deadline.tomorrow
      end
      return deadline.strftime("%d/%m/%Y")
    else
      return nil
    end
  end

  def generate_invoice(deposit=false)
    require 'rubygems'
    require 'prawn'
    require "prawn/core"
    require "prawn/layout"
    require 'prawn/format'
    dir = "#{RAILS_ROOT}/public/documents/invoices"
    unless File.directory? dir
      Dir.mkdir dir
    end

    if File.exists? "#{RAILS_ROOT}/public/documents/invoices/#{id}.pdf"
      FileUtils.rm "#{RAILS_ROOT}/public/documents/invoices/#{id}.pdf"
    end

    booking = self

    Prawn::Document.generate("#{RAILS_ROOT}/public/documents/invoices/#{id}.pdf") do

      address_image = "#{RAILS_ROOT}/public/images/admin/invoice_address.png"
      image(open(address_image), :position => :right, :vposition => 0)

      if deposit
        text "Statement", :align => :left, :size => 25
      else
        text "Cash Invoice", :align => :left, :size => 25
      end

      text = deposit ? "Reference number:" : "Invoice number:"
      table([[booking.user.name, text, "#{booking.id}"],
             ["", "Invoice date:", "#{booking.created_at.strftime("%d/%m/%Y")}"]],
            :border_style => :underline_header,
            :font_size => 14,
            :column_widths => {0 => 340, 1 => 120, 2 => 80},
            :align => {0 => :left, 1 => :left, 2 => :right})

      move_down 20

      data = []
      for booking_item in booking.booking_items
        description = "#{booking_item.first_name} #{booking_item.last_name} - #{booking_item.trip.name}"
        for product in booking_item.products
          description += " - " + product.name
        end
        description += booking_item.upgrade ? " - with upgrade":""
        data << [description, "£#{sprintf('%.2f', booking_item.subtotal)}"]
      end

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

      table([["Booking Fee","£#{sprintf('%.2f', booking.booking_fee)}"]],
            :border_style => :underline_header,
            :column_widths => {0 => 470, 1 => 70},
            :align => {0 => :left, 1 => :right})

      if deposit

        table([["Paid","£#{sprintf('%.2f', booking.paid)}"]],
              :border_style => :underline_header,
              :column_widths => {0 => 470, 1 => 70},
              :align => {0 => :left, 1 => :right})

        table([["Outstanding Amount","£#{sprintf('%.2f', booking.outstanding_balance)}"]],
              :border_style => :underline_header,
              :column_widths => {0 => 470, 1 => 70},
              :align => {0 => :left, 1 => :right})

      else

        table([["Invoice Total","£#{sprintf('%.2f', booking.total)}"]],
              :border_style => :underline_header,
              :column_widths => {0 => 470, 1 => 70},
              :align => {0 => :left, 1 => :right})

      end

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
        table([["Don’t be a tourist Limited", "Company number: 5913320", "Registered in England at 15 Queen Square Leeds LS2 8AJ"]],
              :border_style => :underline_header,
              :column_widths => {0 => 140, 1 => 180, 2 => 220},
              :font_size => 8,
              :align => {0 => :left, 1 => :center, 2 => :right},
              :vpositon => :bottom)
      end
    end
  end

end
