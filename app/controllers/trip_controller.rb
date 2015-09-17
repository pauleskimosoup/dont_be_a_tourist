class TripController < ApplicationController

  layout "web"

  before_filter :initialize_basket, :only => [:book]
  around_filter :catch_not_found

  def index
    redirect_to :action => 'list'
  end

  def list
    @trip_groups = TripGroup.find(:all)
    @all_trips = Trip.all(:conditions => ["trips.display = ? AND trips.start_date >=? AND trips.highlight = ?", true, Date.today, true], :order => :start_date)
    @universities = University.all(:conditions => {:display => true}, :order => :name)



    unless params[:order].blank?
      @trips = Trip.all(:conditions => ["display=? AND start_date>=? AND highlight = ?", true, Date.today, true], :order => 'start_date asc', :order => params[:order])
    else
      @trips = Trip.on_list
    end

  end

  def search
    @trip_groups = TripGroup.find(:all)
    @all_trips = Trip.all(:conditions => ["trips.display = ? AND trips.start_date >=? AND trips.highlight = ?", true, Date.today, true], :order => :start_date)
    @universities = University.all(:conditions => {:display => true}, :order => :name)



    unless params[:trip_group_id].blank?
      @specific_trip_group = TripGroup.find(params[:trip_group_id])
    end

    unless params[:university].blank?
      @specific_university = University.find(params[:university])
    end

    unless params[:order].blank?

      unless params[:search_criteria].blank?
        #@trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.name LIKE ? AND trips.display=? AND trips.start_date >=?", "%#{params[:search_criteria]}%", true, Date.today], :order => params[:order]).uniq
        @trips = Trip.find(:all, :conditions => ["trips.name LIKE ? AND trips.display=? AND trips.start_date >=?", "%#{params[:search_criteria]}%", true, Date.today], :order => params[:order]).uniq
      end

      unless params[:trip_group_id].blank?
        #@trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.trip_group_id = ? AND trips.display=? AND trips.start_date >=?", params[:trip_group_id], true, Date.today], :order => params[:order]).uniq
        @trips = Trip.find(:all, :conditions => ["trips.trip_group_id = ? AND trips.display=? AND trips.start_date >=?", params[:trip_group_id], true, Date.today], :order => params[:order]).uniq
      end

      unless params[:university].blank?
        @trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.display=? AND trips.start_date >=? AND trip_ownerships.university_id = ?", true, Date.today, params[:university]], :order => params[:order]).uniq
      end

    else

      unless params[:search_criteria].blank?
        #@trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.name LIKE ? AND trips.display=? AND trips.start_date >=?", "%#{params[:search_criteria]}%", true, Date.today], :order => :start_date).uniq
        @trips = Trip.find(:all, :conditions => ["trips.name LIKE ? AND trips.display=? AND trips.start_date >=?", "%#{params[:search_criteria]}%", true, Date.today], :order => :start_date).uniq
      end

      unless params[:trip_group_id].blank?
        #@trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.trip_group_id = ? AND trips.display=? AND trips.start_date >=?", params[:trip_group_id], true, Date.today], :order => :start_date).uniq
        @trips = Trip.find(:all, :conditions => ["trips.trip_group_id = ? AND trips.display=? AND trips.start_date >=?", params[:trip_group_id], true, Date.today], :order => :start_date).uniq
      end

      unless params[:university].blank?
        @trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.display=? AND trips.start_date >=? AND trip_ownerships.university_id = ?", true, Date.today, params[:university]], :order => :start_date).uniq
      end

    end



  end

  def show
    @trip = Trip.find(params[:id])

    if @trip.start_date < Date.today
      #redirect_to :controller => :web, :action => :past_trips, :trip => @trip.id
      redirect_to root_url
      return
    end
    @destinations = @trip.destinations
    @destination = @trip.destinations.sort_by{rand}.first
    @activities = @trip.activities
    if !@destinations.empty?
      @reviews = Review.random(3, :destination_id => @destination.id)
    end
    @pickups = @trip.pickups
    unless @trip.display?
      redirect_to :action => 'list'
    end
    @pictures_count = 0
    @pictures_array = Array.new
    if @trip.photo_1?
      @pictures_count += 1
      @pictures_array << 1
    end
    if @trip.photo_2?
      @pictures_count += 1
      @pictures_array << 2
    end
    if @trip.photo_3?
      @pictures_count += 1
      @pictures_array << 3
    end
    if @trip.photo_4?
      @pictures_count += 1
      @pictures_array << 4
    end

  end

  def show_more
    respond_to do |type|
      type.js {
        render :update do |page|
          page["activity_#{params[:activity]}"].toggle
        end
      }
    end
  end

  private

  def catch_not_found
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url
  end

end
