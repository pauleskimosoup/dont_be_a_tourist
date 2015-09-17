class FlagAdminController < ApplicationController
  
  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin
  
  def index
    redirect_to :action => 'list'
  end
  
  def list
    @list_name = :flag_admin_list
    update_session
    @flags, @flag_pages = Flag.paginate_and_order(session[@list_name])
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
      @flag = Flag.new(:display => true)
    else
      @flag = Flag.new(params[:flag])
      if @flag.save
        flash[:notice] = "The Flag was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that Flag."
        flash[:error_field] = :flag
      end
    end
  end
  
  def edit
    @flag = Flag.find(params[:id])
    if request.post?
      if @flag.update_attributes(params[:flag])
        flash[:notice] = "The Flag was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that Flag."
        flash[:error_field] = :flag
      end
    end
  end
  
  def delete
    @flag = Flag.find(params[:id])
    if @flag.destroy
      flash[:notice] = "That Flag was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that Flag."
    end
    redirect_to :action => 'list'
  end
  
end
