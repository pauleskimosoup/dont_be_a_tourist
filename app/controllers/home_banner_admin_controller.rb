class HomeBannerAdminController < ApplicationController
  
  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin
  
  def index
    redirect_to :action => 'list'
  end
  
  def list
    @list_name = :home_banner_admin_list
    update_session
    @banners, @banner_pages = HomeBanner.paginate_and_order(session[@list_name])
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
      @banner = HomeBanner.new
    else
      @banner = HomeBanner.new(params[:home_banner])
      if @banner.save
        flash[:notice] = "The Home Banner was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that Home Banner."
        flash[:error_field] = :home_banner
      end
    end
  end
  
  def edit
    @banner = HomeBanner.find(params[:id])
    if request.post?
      if @banner.update_attributes(params[:home_banner])
        flash[:notice] = "The Home Banner was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that Home Banner."
        flash[:error_field] = :home_banner
      end
    end
  end
  
  def delete
    @banner = HomeBanner.find(params[:id])
    if @banner.destroy
      flash[:notice] = "That Home Banner was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that Home Banner."
    end
    redirect_to :action => 'list'
  end
  
end
