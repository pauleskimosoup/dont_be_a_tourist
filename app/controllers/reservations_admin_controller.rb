class ReservationsAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :reservation_admin_list
    update_session
    @reservation, @reservation_pages = Reservation.paginate_and_order(session[@list_name])
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
      @reservation = Reservation.new
    else
      @reservation = Reservation.new(params[:reservation])
      if @reservation.save
        flash[:notice] = "The reservation was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that reservation."
        flash[:error_field] = :reservation
      end
    end
  end

  def edit

    @reservation = Reservation.find(params[:id])
    if request.post?
      if @reservation.update_attributes(params[:reservation])
        flash[:notice] = "The reservation was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that reservation."
        flash[:error_field] = :reservation
      end
    end
  end

  def delete
    @reservation = Reservation.find(params[:id])
    if @reservation.destroy
      flash[:notice] = "That reservation was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that reservation."
    end
    redirect_to :action => 'list'
  end


end
