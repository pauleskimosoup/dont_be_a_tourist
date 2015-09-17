class DestinationAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :destination_admin_list
    update_session
    @destinations, @destination_pages = Destination.paginate_and_order(session[@list_name])
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
      @destination = Destination.new
    else
      @destination = Destination.new(params[:destination])
      if @destination.save
        flash[:notice] = "The destination was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that destination."
        flash[:error_field] = :destination
      end
    end
  end

  def edit

    @destination = Destination.find(params[:id])
    if request.post?
      if @destination.update_attributes(params[:destination])
        flash[:notice] = "The destination was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that destination."
        flash[:error_field] = :destination
      end
    end
  end

  def delete
    @destination = Destination.find(params[:id])
    if @destination.destroy
      flash[:notice] = "That destination was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that destination."
    end
    redirect_to :action => 'list'
  end


end
