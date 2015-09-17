class PickupController < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @pickups, @pickup_pages = Pickup.paginate_and_order(params.merge({:conditions => "display=1"}))
  end

  def show
    @pickup = Pickup.find(params[:id])
    unless @pickup.display?
      redirect_to :action => 'list'
    end
  end

end
