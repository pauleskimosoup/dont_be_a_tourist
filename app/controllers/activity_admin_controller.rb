class ActivityAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :activity_admin_list
    update_session
    @activities, @activity_pages = Activity.paginate_and_order(session[@list_name])
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
      @activity = Activity.new
    else
      @activity = Activity.new(params[:activity])
      if @activity.save
        flash[:notice] = "The activity was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that activity."
        flash[:error_field] = :activity
      end
    end
  end

  def edit

    @activity = Activity.find(params[:id])
    if request.post?
      if @activity.update_attributes(params[:activity])
        flash[:notice] = "The activity was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that activity."
        flash[:error_field] = :activity
      end
    end
  end

  def delete
    @activity = Activity.find(params[:id])
    if @activity.destroy
      flash[:notice] = "That activity was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that activity."
    end
    redirect_to :action => 'list'
  end


end
