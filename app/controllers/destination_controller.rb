class DestinationController < ApplicationController

  layout "web"
    
  def index
    redirect_to :action => 'list'
  end

  def list
    session
    @destinations, @destination_pages = Destination.paginate_and_order(params.merge({:conditions => "display=1", :order_field => "name", :order_direction => "ASC"}))
  end

  def show
    @destination = Destination.find(params[:id])
    unless @destination.display?
      redirect_to :action => 'list'
    end
  end

end
