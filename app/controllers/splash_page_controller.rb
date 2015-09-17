class SplashPageController < ApplicationController
  
  layout 'web'

  def show
    @splash_page = SplashPage.find_by_url(params[:id])
    unless @splash_page && @splash_page.display?
      flash[:notice] = 'This promotion is not active at the moment.'
      redirect_to root_url
    end
    @user = User.new(params[:user])
  end
  
  def redeem
    @splash_page = SplashPage.find_by_url(params[:id])
    @user = User.new(params[:user])
    if @user.save
      @splash_page.promo_codes.each{|x| @user.promo_codes << x}
      flash[:notice] = "You have successfully signed up and applied a promo code to your account, now choose the trip you would like to go on!"
      session[:user_id] = @user.id
      redirect_to :controller => 'trip', :action => 'list', :anchor => "trips"
    else
      render :action => "show"
    end
  end

end
