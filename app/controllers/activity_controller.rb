class ActivityController < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @activities, @activity_pages = Activity.paginate_and_order(params.merge({:conditions => "display=1"}))
  end

  def show
    @activity = Activity.find(params[:id])
    unless @activity.display?
      redirect_to :action => 'list'
    end
  end

end
