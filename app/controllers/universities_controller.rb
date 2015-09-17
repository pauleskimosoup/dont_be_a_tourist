class UniversitiesController < ApplicationController

  layout "web"

  def show
    @banners = BenefitBanner.past_random(8)
    @university = University.find(params[:id])
    
    @trip_groups    = TripGroup.find(:all)
    
    @national_trips = Trip.all(:conditions => ["trips.display = ? AND trips.start_date >=? AND trips.highlight = ?", true, Date.today, true], :order => :start_date).uniq
    @trips = Trip.find(:all, :joins => :trip_ownerships, :conditions => ["trips.display=? AND trips.start_date >=? AND trip_ownerships.university_id = ?", true, Date.today, @university.id], :order => :start_date).uniq

  end

end