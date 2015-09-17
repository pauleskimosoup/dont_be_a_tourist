class RoomAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    @trip = Trip.find(params[:trip_id])
    @rooms = Room.find(:all, :conditions => {:trip_id => @trip.id})
    @rooms, @room_pages = Pager.pages(@rooms, params[:page], 100)
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
    @room = Room.new(:trip_id => params[:trip_id])
  end
  
  def create
    @room = Room.new(params[:room])
    if @room.save
      redirect_to :action => "index", :trip_id => @room.trip_id   
    else
      flash[:error] = "There was a problem creating this room"
      render :action => "new"
    end
  end
  
  def edit
    @room = Room.find(params[:id])
  end
  
  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(params[:room])
      redirect_to :action => "index", :trip_id => @room.trip_id
    else
      flash[:error] = "There was a problem updating this room"
    end
  end
  
  def delete
    @room = Room.find(params[:id])
    room_trip_id = @room.trip.id
    if @room.destroy
      flash[:notice] = "That room was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that room."
    end
    redirect_to :action => 'index', :trip_id => room_trip_id
  end
  
  def details
    @trip = Trip.find(params[:trip_id])
    @possibilities = @trip.booking_items.dup
  end
  
  def details_csv
    @trip = Trip.find(params[:trip_id])
    @possibilities = @trip.booking_items.dup
    require 'csv'
    list = StringIO.new
    CSV::Writer.generate(list, ',') do |body|
    
      for room in params[:rooms].split('-')

        if room.include?("m")
          room_gender = "Man"
        elsif room.include?("f")
          room_gender = "Woman"
        else
          room_gender = "Person"
        end
    
        body << ["#{room.to_i} #{room_gender} Room", ""]
    
        room.to_i.times do
    
          if room_gender == "Man"
            person = @possibilities.select{|x| x.gender == "Male"}.first
          elsif room_gender == "Woman"
            person = @possibilities.select{|x| x.gender == "Female"}.first
          end
        
          if person
            body << ["", "#{person.first_name} #{person.last_name} #{person.booking.user.stars}"]
            @possibilities.delete(person)
          else
            body << ["","______________________"]
          end
      
        end
        
        body << []
        
      end
    end
    
    list.rewind
    send_data(list.read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => 'room_config.csv', :disposition => 'attachment', :encoding => 'utf8')
  end

end
