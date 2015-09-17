class BookingController < ApplicationController

  layout 'web'

  before_filter :authorize_user

  protect_from_forgery :except => [:result]

  def complete
    @booking = Booking.find(params[:id])
    unless @current_user == @booking.user
      flash[:error] = "You are not authorized to view that booking"
      redirect_to :controller => "user", :action => "home"
    end
  end

  def result
    @last_trip = Trip.first(:joins => "LEFT OUTER JOIN booking_items ON booking_items.trip_id = trips.id LEFT OUTER JOIN bookings ON booking_items.booking_id = bookings.id",
                               :conditions => ["bookings.user_id = ? AND trips.promoted_trip_id IS NOT NULL", @current_user.id],
                               :order => "bookings.created_at DESC")
    @trip = @last_trip.promoted_trip if @last_trip

    if @trip && @trip.display? && @trip.start_date > Date.today
      @destinations = @trip.destinations
      @destination = @trip.destinations.sort_by{rand}.first
      @activities = @trip.activities
      if !@destinations.empty?
        @reviews = Review.random(3, :destination_id => @destination.id)
      end
      @pickups = @trip.pickups
      render "trip/show"
    else
      @feedback = Feedback.new
    end
  end

end
