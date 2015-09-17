class BenefitBannerAdminController < ApplicationController
  
  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin
  
  def index
    redirect_to :action => 'list'
  end
  
  def list
    @list_name = :benefit_banner_admin_list
    update_session
    @banners, @banner_pages = BenefitBanner.paginate_and_order(session[@list_name])
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
      @banner = BenefitBanner.new
    else
      @banner = BenefitBanner.new(params[:benefit_banner])
      if @banner.save
        flash[:notice] = "The Benefit Banner was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that Benefit Banner."
        flash[:error_field] = :benefit_banner
      end
    end
  end
  
  def edit
    @banner = BenefitBanner.find(params[:id])
    if request.post?
      if @banner.update_attributes(params[:benefit_banner])
        flash[:notice] = "The Benefit Banner was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that Benefit Banner."
        flash[:error_field] = :benefit_banner
      end
    end
  end
  
  def delete
    @banner = BenefitBanner.find(params[:id])
    if @banner.destroy
      flash[:notice] = "That Benefit Banner was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that Benefit Banner."
    end
    redirect_to :action => 'list'
  end
  
end
