class TripAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :trip_admin_list
    update_session
    @trips, @trip_pages = Trip.paginate_and_order(session[@list_name])
  end

  def update_session
    unless session[@list_name]
      session[@list_name] = {}
    end
    [:page, :order_direction, :order_field, :search].each do |param|
      if params[param]
        session[@list_name][param] = params[param]
      end
    end
  end

  def new
    redirect_to :action => :new_step_1
  end

  def new_step_1
    if request.get?
      @trip = Trip.new
    else
      @trip = Trip.new(params[:trip])
      if @trip.save
        redirect_to :action => 'new_step_2', :id => @trip.id
      else
        flash[:notice] = "Sorry, there was a problem creating that trip."
        flash[:error_field] = :trip
      end
    end
  end

  def new_step_2

    @trip = Trip.find(params[:id])
    #@trip.itinerary = @trip.default_itinerary
    if request.post?
      params[:trip][:product_ids] ||= []
      params[:trip][:activity_ids] ||= []
      if @trip.update_attributes(params[:trip])
        flash[:notice] = "The trip was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that trip."
        flash[:error_field] = :trip
      end
    end
  end

  def edit
    @trip = Trip.find(params[:id])
    if @trip.itinerary == nil
      #@trip.itinerary = @trip.default_itinerary
    end

    if request.post?
      params[:trip][:product_ids] ||= []
      params[:trip][:activity_ids] ||= []
      if @trip.update_attributes(params[:trip])
        flash[:notice] = "The trip was successfully updated."
        redirect_to :action => :edit, :id => @trip.id
      else
        flash[:notice] = "Sorry, there was a problem creating that trip."
        flash[:error_field] = :trip
      end
    end
  end

  def delete
    @trip = Trip.find(params[:id])
    if @trip.destroy
      flash[:notice] = "That trip was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that trip."
    end
    redirect_to :action => 'list'
  end

  def list_people
    @trip = Trip.find(params[:id])
    @list_name = :trip_booking_admin_list
    session[@list_name] ||= {}
    session[@list_name][:order_field] ||= 'last_name'
    update_session
    @bookings, @booking_pages = BookingItem.paginate_and_order(session[@list_name].merge(:conditions => "trip_id = #{@trip.id}"))
    @cancelled_bookings, @cancelled_booking_pages = CancelledBookingItem.paginate_and_order(session[@list_name].merge(:order_field => 'last_name', :conditions => "trip_id = #{@trip.id}"))
  end

  def list_people_csv
    require 'csv'
    list = StringIO.new
    @trip = Trip.find(params[:id])
    @bookings = BookingItem.find(:all, :conditions => "trip_id = #{@trip.id}")
    CSV::Writer.generate(list, ',') do |body|
      body << [@trip.name_dates]
      body << ['',
               'Booking Ref',
               'First name',
               'Surname',
               'Sex',
               'Mobile',
               'Email address',
               'Uni',
               'Pickup/Dropoff',
               'Method',
               'Booking created',
               'Payment',
               'Recieved',
               'Extras',
               'Discount Code',
               'Total',
               'Comments']
      body << []

      index = 0
      first_in_booking = true
      current_booking_id = 0
      @bookings.sort_by{|x| x.booking.id}.each do |b|

        if b.booking.id != current_booking_id
          current_booking_id = b.booking.id
          booking_ref = b.booking.id
          phone = b.booking.user.phone
          email = b.booking.user.email
          university = b.booking.user.university
          booking_type = b.booking.booking_type
          booking_status = b.booking.booking_status
          received = b.booking.paid
          total = b.booking.total
          notes = b.booking.notes
        else
          booking_ref = ''
          phone = ''
          email = ''
          university = ''
          booking_status = ''
          recieved = ''
          total = ''
          notes = ''
        end

        index += 1
        if b.booking.booking_status == "paid"
          @received = b.subtotal
        else
          @received = b.subtotal - b.booking.outstanding_balance
        end
        body << [index,
                 booking_ref,
                 b.first_name,
                 b.last_name,
                 b.gender[0, 1],
                 phone,
                 email,
                 university,
                 b.pickup_dropoff,
                 booking_type,
                 b.created_at.strftime("%H:%M on %a %d/%m/%y"),
                 booking_status,
                 received,
                 b.products.collect{|p| p.name}.to_sentence,
                 b.booking.discount_code_name,
                 total,
                 notes]
      end
    end
    list.rewind
    send_data(list.read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "#{@trip.name.gsub(/\W/, '_')}_booking_list_downloaded_#{Time.now.strftime("%I_%M_%p_%d_%m_%y")}.csv", :disposition => 'attachment', :encoding => 'utf8')
  end

  def list_people_pickup_csv
    require 'csv'
    list = StringIO.new
    @trip = Trip.find(params[:id])
    @bookings = BookingItem.find(:all, :conditions => "trip_id = #{@trip.id}")

    # Sort
    @bookings = @bookings.sort_by{|x| [x.pick_time, x.first_name]}

    CSV::Writer.generate(list, ',') do |body|
      body << [@trip.name_dates]
      body << ['',
               'Pickup/Dropoff',
               'First name',
               'Last name',
               'Gender',
               'Mobile phone',
               'Nationality',
               'Passport no.',
               'Signature',
               'Extras',
               'Discount Code',
               'Note']

      body << []

      index = 0
      @bookings.each do |b|
        index += 1
        body << [index,
                 b.pickup_dropoff,
                 b.first_name,
                 b.last_name,
                 b.gender[0, 1],
                 b.booking.user.phone,
                 '',
                 '',
                 '',
                 b.products.collect{|p| p.name}.to_sentence,
                 b.booking.discount_code_name,
                 b.booking.notes]
      end
    end

    list.rewind
    send_data(list.read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "#{@trip.name.gsub(/\W/, '_')}_pickup_list_downloaded_#{Time.now.strftime("%I_%M_%p_%d_%m_%y")}.csv", :disposition => 'attachment', :encoding => 'utf8')
  end

  # TODO finish this off and get it to duplicate the associations and pictures
  def duplicate
    original_trip = Trip.find(params[:id])
    @trip = original_trip.clone
    @trip.name = "Copy of #{@trip.name}"
    @trip.photo_1 = original_trip.photo_1 unless original_trip.photo_1.blank?
    @trip.photo_2 = original_trip.photo_2 unless original_trip.photo_2.blank?
    @trip.photo_3 = original_trip.photo_3 unless original_trip.photo_3.blank?
    @trip.photo_4 = original_trip.photo_4 unless original_trip.photo_4.blank?
    original_trip.products.each{|x| @trip.products << x}
    original_trip.destinations.each{|x| @trip.destinations << x}
    original_trip.accommodations.each{|x| @trip.accommodations << x}
    original_trip.activities.each{|x| @trip.activities << x}
    original_trip.pickup_dropoff_times.each{|x| @trip.pickup_dropoff_times << x.clone}
    @trip.pickup_dropoff_times.each do |pickup_time|
      if pickup_time.limit == nil
        pickup_time.update_attribute(:limit, 0)
      end
      pickup_time.update_attribute(:places_cache, 0)
    end
    #original_trip.pickups.each{|x| @trip.pickups << x}
    @trip.display = false
    if @trip.save
      #for trip_flag in trip_flags
      #  TripFlag.create(:country_code => trip_flag.country_code, :trip_id => @trip.id)
      #end
      for room in original_trip.rooms
        Room.create(:places => room.places, :trip_id => @trip.id)
      end
      flash[:notice] = "Trip duplicated"
      redirect_to :action => "list"
    else
      flash[:notice] = "Could not duplicate trip"
    end
  end

  def update_notes
    @trip = Trip.find(params[:id])
    if @trip.update_attributes(params[:trip])
      flash[:notice] = "The Room Notes for this trip were successfully updated."
    else
      flash[:error] = "Sorry, there was a problem updating the room notes for that trip. Please try again."
    end
    redirect_to :controller => "room_admin", :trip_id => @trip.id
  end

end
