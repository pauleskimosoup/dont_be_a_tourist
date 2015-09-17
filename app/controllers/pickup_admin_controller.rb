class PickupAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :pickup_admin_list
    update_session
    @pickups, @pickup_pages = Pickup.paginate_and_order(session[@list_name])
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
    if request.get?
      @pickup = Pickup.new
    else
      @pickup = Pickup.new(params[:pickup])
      if @pickup.save
        flash[:notice] = "The pickup was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that pickup."
        flash[:error_field] = :pickup
      end
    end
  end

  def edit

    @pickup = Pickup.find(params[:id])
    if request.post?
      if @pickup.update_attributes(params[:pickup])
        flash[:notice] = "The pickup was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that pickup."
        flash[:error_field] = :pickup
      end
    end
  end

  def delete
    @pickup = Pickup.find(params[:id])
    if @pickup.destroy
      flash[:notice] = "That pickup was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that pickup."
    end
    redirect_to :action => 'list'
  end


end
