class DayItineraryAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin


  def index
    @trip = Trip.find(params[:trip_id])
    @day_itineraries = DayItinerary.find(:all, :conditions => {:trip_id => @trip.id}, :order => :day)
    @day_itineraries, @day_itineraries_pages = Pager.pages(@day_itineraries, params[:page], 100)
  end

  def new
    @day_itinerary = DayItinerary.new(:trip_id => params[:trip_id])
    @trip = Trip.find(params[:trip_id])
  end

  def create
    @day_itinerary = DayItinerary.new(params[:day_itinerary])
    if @day_itinerary .save
      redirect_to :action => "index", :trip_id => @day_itinerary.trip_id
    else
      @trip = Trip.find(@day_itinerary.trip_id)
      flash[:error] = "There was a problem creating this day itinerary"
      render :action => "new"
    end

  end

  def edit
    @day_itinerary = DayItinerary.find(params[:id])
    @trip = Trip.find(@day_itinerary.trip_id)
  end

  def update
    @day_itinerary = DayItinerary.find(params[:id])
    if @day_itinerary.update_attributes(params[:day_itinerary])
      redirect_to :action => "index", :trip_id => @day_itinerary.trip_id
    else
      @trip = Trip.find(@day_itinerary.trip_id)
      flash[:error] = "There was a problem updating this day itinerary"
      render :action => "edit"
    end
  end

  def destroy
    @day_itinerary = DayItinerary.find(params[:id])
    trip_id = @day_itinerary.trip.id
    if @day_itinerary.destroy
      flash[:notice] = "That day itinerary was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that day itinerary"
    end
    redirect_to :action => 'index', :trip_id => trip_id
  end

  def delete
    @day_itinerary = DayItinerary.find(params[:id])
    trip_id = @day_itinerary.trip.id
    if @day_itinerary.destroy
      flash[:notice] = "That day itinerary was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that day itinerary"
    end
    redirect_to :action => 'index', :trip_id => trip_id
  end

end
