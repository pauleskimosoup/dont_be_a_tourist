class TripGroupsAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => "list"
  end

  def list
    @trip_groups = TripGroup.find(:all, :order => (params[:order] ||= :name))
    @trip_groups, @trip_groups_pages = Pager.pages(@trip_groups, params[:page], 100)
  end

  def new
    @trip_group = TripGroup.new
  end

  def edit
    @trip_group = TripGroup.find(params[:id])
  end

  def create
    @trip_group = TripGroup.new(params[:trip_group])

    if @trip_group.save
      redirect_to(:action => "list", :notice => 'TripGroup was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @trip_group = TripGroup.find(params[:id])


    if @trip_group.update_attributes(params[:trip_group])
      redirect_to(:action => "list", :notice => 'TripGroup was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def delete
    @trip_group = TripGroup.find(params[:id])
    @trip_group.destroy
    redirect_to(:controller => "trip_groups_admin", :action => "index")
  end
end