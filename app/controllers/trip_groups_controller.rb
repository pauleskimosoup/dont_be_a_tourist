class TripGroupsController < ApplicationController

  layout "web"

  def index
    @trip_groups = TripGroup.find(:all)
  end

  def show
    @trip_group = TripGroup.find(params[:id])
    @trips = @trip_group.trips.find(:all, :conditions => ["display=? AND start_date>=?", true, Date.today], :order => 'start_date asc')
  end
end
