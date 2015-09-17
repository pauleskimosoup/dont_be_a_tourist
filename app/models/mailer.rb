class Mailer < ActionMailer::Base

  def mail_shot(to, from, subject, body)
    @recipients = to
    @from = from
    @subject = subject
    @body[:body] = body
  end

  def welcome(email, code)
    @subject = 'Welcome Promotion Interest'
    @body[:email] = email
    @body[:code] = code
    @recipients = SiteProfile.first.email
    @from = "info@dontbeatourist.co.uk"
  end

  def contact_recieved(dump)
    unless /\S+?@\S+?\.\S+?/ =~ dump[:email]
      dump[:email] = "info@dontbeatourist.co.uk"
      @subject = 'Contact form filled out (no reply email address supplied)'
    else
      @subject = 'Contact form filled out'
    end
    @body[:dump] = dump
    @recipients  = SiteProfile.find(:first).email
    #@bcc         = "adam@eskimosoup.co.uk"
    @from = dump[:email]
  end

  def welcome_admin(admin, password)
    @subject = 'T Media Admin'
    @body[:password] = password
    @body[:name] = admin.name
    @recipients = admin.email
    @from = "info@dontbeatourist.co.uk"
  end

  def forgotten_password(admin, password)
    @subject = 'T Media Admin'
    @body[:password] =  password
    @body[:name] = admin.name
    @recipients = admin.email
    @from = "info@dontbeatourist.co.uk"
  end

  def new_admin(admin)
    @subject = 'A new admin has signed up'
    @body[:admin] = admin
    @recipients = ['george@tmedia.co.uk', 'hannah@tmedia.co.uk', 'robbie@tmedia.co.uk']
    @from = "info@dontbeatourist.co.uk"
  end

  def content_changed (content, content_type)
    @subject = "A #{content_type} has changed"
    @body[:content] = content
    @recipients = 'info@tmedia.co.uk'
    @from       = 'demo@tmediasolutions.co.uk'
  end

  # sent to a user when they make a booking (via paypal)
  def booking_notice(booking_id)
    booking      = Booking.find(booking_id)
    @subject     = "Your Don\'t be a tourist booking confirmation (ref: #{booking.id})"
    @recipients  = booking.user.email
    #@bcc         = "adam@eskimosoup.co.uk"
    @from        = SiteProfile.first.email
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  # sent to admin when a booking is made
  def booking_info(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "A user has made a booking (reference number #{booking.id})"
    @recipients = SiteProfile.first.email
    #@bcc        = "adam@eskimosoup.co.uk"
    @from       = "info@dontbeatourist.co.uk"
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  # send to a user when they make a cash booking
  def prelim_booking_notice(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "Payment of your Don't be a tourist booking(s)"
    @recipients = booking.user.email
    #@bcc        = "adam@eskimosoup.co.uk"
    @from       = SiteProfile.first.email
    @body[:booking] = booking
    @body[:user] = booking.user
    content_type "text/html"
    if booking.booking_type == 'cash'
      booking.generate_invoice
      attachment(:content_type => 'application/pdf',
                 :body => File.read("#{RAILS_ROOT}/public/documents/invoices/#{booking.id}.pdf"),
                 :filename => 'invoice.pdf')
    end
  end

  # sent to admin when a cash booking is made
  def prelim_booking_info(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "A user has made a preliminary booking (reference number #{booking.id})"
    @recipients = SiteProfile.first.email
    @from       = "info@dontbeatourist.co.uk"
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  # send to a user when a cash booking is paid for
  def payment_recieved_notice(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "Your Don\'t be a Tourist Preliminary Booking (reference number #{booking.id}) Payment Recieved"
    @recipients = booking.user.email
    @from       = SiteProfile.first.email
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  # sent to a user when a booking is paid for
  def booking_cancelled_notice(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "Your Don\'t be a Tourist Booking (reference number #{booking.id}) Has Been Cancelled"
    @recipients = booking.user.email
    @from       = SiteProfile.first.email
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  # sent to admin when a used reserves a place on a trip_has_destination
  def reserve(params)
    @subject    = "A user wants to make a reservation"
    @recipients = SiteProfile.first.email
    @from       = "info@dontbeatourist.co.uk"
    @body[:params] = params
    trip = Trip.find(params[:trip])
    @body[:trip] = trip
  end

  def cash_payment_reminder(booking)
    @subject    = "Payment for your Don't be a Tourist booking"
    @recipients = booking.user.email
    @from       = SiteProfile.first.email
    @body[:booking] = booking
    content_type "text/html"
  end

  def payment_reminder(booking)
    @subject    = "Payment for your Don't be a Tourist booking"
    @recipients = booking.user.email
    @from       = SiteProfile.first.email
    @body[:booking] = booking
    content_type "text/html"
  end

  def admin_payment_reminder(booking_id)
    booking     = Booking.find(booking_id)
    @subject    = "Payment for your Don\'t be a Tourist Booking (reference number #{booking.id})"
    @recipients = booking.user.email
    @from       = SiteProfile.first.email
    content_type "text/html"
    @body[:booking] = booking
    @body[:user] = booking.user
  end

  def user_welcome_and_details(user, new_password)
    @subject     = "Your Don\'t be a Tourist Account Details"
    @recipients  = user.email
    @from        = SiteProfile.first.email
    @body[:user] = user
    @body[:new_password] = new_password
  end

  def payment_problem(basket, problem)
    @subject        = "There was a problem with your tourist"
    @recipients     = basket.user.email
    @from           = SiteProfile.first.email
    @body[:problem] = problem
    content_type "text/html"
  end

  # send to a user when a the admin makes a payment to the booking (unless its a full payment)
  def deposit_update(booking_id)
    booking         = Booking.find(booking_id)
    @subject        = "Your Don\'t be a Tourist Preliminary Booking (reference number #{booking.id}) Deposit Update"
    @recipients     = booking.user.email
    @from           = SiteProfile.first.email
    @body[:booking] = booking
    @body[:user]     = booking.user
    content_type "text/html"
    booking.generate_invoice(true)
    attachment(:content_type => 'application/pdf',
               :body => File.read("#{RAILS_ROOT}/public/documents/invoices/#{booking.id}.pdf"),
               :filename => 'invoice.pdf')
  end

  def sharing_rooms(name, trip, sharing_options)
    @subject = "Room sharing requested"
    @recipients = SiteProfile.first.email
    @from       = SiteProfile.first.email
    @body[:name] = name
    @body[:trip] = trip
    @body[:sharing_options] = sharing_options
    content_type "text/html"
  end

  def feedback(message)
    @subject = "Feedback form filled in"
    @recipients = 'info@dontbeatourist.co.uk'
    @from = 'info@dontbeatourist.co.uk'
    @body[:message] = message
    content_type "text/html"
  end

  def test(email)
    @subject = "Test"
    @recipients = email
    @from = SiteProfile.first.email
    content_type "text/html"
  end

end
