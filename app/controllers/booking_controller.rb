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
    @feedback = Feedback.new
  end
  
end
