class PromoCodeController < ApplicationController

  before_filter :initialize_basket, :only => [:book]

  def enter_code
    if params[:code].blank?
      flash[:error] = "Please enter a code."
      redirect_to :controller => "basket", :action => "show"
      return      
    end
    
    promo_code = PromoCode.find_by_code(params[:code])  
    if promo_code && promo_code.code_type?
      if promo_code.active?
        @current_basket.promo_code = promo_code
        @current_basket.save
        flash[:notice] = "Code applied to basket"
      else
        flash[:error] = "Sorry, that code isn't active at the moment"  
      end
    else
      flash[:error] = "Sorry, we can't find that promotional code, are you sure you entered it correctly?"
    end
    redirect_to :controller => "basket", :action => "show"
  end
  
  def remove_code
    @current_basket.promo_code = nil
    @current_basket.save
    flash[:notice] = "Code removed"
    redirect_to :controller => "basket", :action => "show"    
  end

end
