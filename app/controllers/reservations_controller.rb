class ReservationsController < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @reservation, @reservation_pages = Reservation.paginate_and_order(params.merge({:conditions => "display=1"}))
  end

  def show
    @reservation = Reservation.find(params[:id])
    unless @reservation.display?
      redirect_to :action => 'list'
    end
  end

end
