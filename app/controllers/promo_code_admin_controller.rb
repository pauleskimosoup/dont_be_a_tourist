class PromoCodeAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end
  
  def all_off_homepage
    for promo_code in PromoCode.all
      promo_code.update_attribute(:homepage, false)
    end
    flash[:notice] = "Removed from homepage."
    redirect_to :action => "list"
  end
  
  def set_homepage
    @promo_code = PromoCode.find(params[:id])
    for promo_code in PromoCode.all
      promo_code.update_attribute(:homepage, false)
    end
    @promo_code.update_attribute(:homepage, true)
    flash[:notice] = "Set to homepage."
    redirect_to :action => "list"
  end
  

  def list
    @list_name = :promo_code_admin_list
    update_session
    @promo_codes, @promo_code_pages = PromoCode.paginate_and_order(session[@list_name])
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
      @promo_code = PromoCode.new(PromoCode.default_attributes)
    else
      @promo_code = PromoCode.new(params[:promo_code])
      if @promo_code.save
        flash[:notice] = "The promo code was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that promo_code."
        flash[:error_field] = :promo_code
      end
    end
  end

  def edit
    @promo_code = PromoCode.find(params[:id])
    if request.post?
      params[:promo_code][:product_ids] ||= []
      params[:promo_code][:linked_promo_code_ids] ||= []
      if @promo_code.update_attributes(params[:promo_code])
        flash[:notice] = "The promo code was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem editing that promo code."
        flash[:error_field] = :promo_code
      end
    end
  end

  def delete
    @promo_code = PromoCode.find(params[:id])
    if @promo_code.destroy
      flash[:notice] = "That promo code was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that promo code."
    end
    redirect_to :action => 'list'
  end
  
  def update_activation_type
    render :update do |page| 
      if params[:activation_type] == '3'
        page[:splash].show
      else
        page[:splash].hide
      end
    end 
  end

end
