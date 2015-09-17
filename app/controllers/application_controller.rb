class ApplicationController < ActionController::Base

  helper :all
  protect_from_forgery


  def booking_fee
    2.5
  end

  helper_method :booking_fee

  before_filter :check_basket


  def initialize_basket
    if session[:basket_id]
      if Basket.exists?(session[:basket_id])
        @basket = Basket.find(session[:basket_id])
      else
        @basket = Basket.create
        @basket.save
        session[:basket_id] = @basket.id
      end
    else
      @basket = Basket.create
      @basket.save
      session[:basket_id] = @basket.id
    end
    if @basket.user == nil && session[:user_id] && User.exists?(session[:user_id])
      @basket.user = User.find(session[:user_id])
      @basket.save
    end
  end

  def check_basket
    if session[:basket_id] && Basket.exists?(session[:basket_id])
      @current_basket = Basket.find(session[:basket_id])
      if @current_basket.basket_items.length < 1
        @current_basket.destroy
        initialize_basket
        if session[:basket_id] && Basket.exists?(session[:basket_id])
          @current_basket = Basket.find(session[:basket_id])
        end
      else
        @current_basket.save!
      end
    end
  end

  def authorize
    unless session[:admin_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    else
      begin
        admin = Admin.find(session[:admin_id])
        unless admin and (admin.has_permission?(self.class.to_s))
          flash[:notice] = "You don't have permission to access that area."
          redirect_to(:controller => "login", :action => 'home')
        end
      rescue ActiveRecord::RecordNotFound
        session[:admin_id] = nil
        flash[:notice] = "You have been unexpectedly logged off. Sorry."
        redirect_to(:controller => 'login', :action => 'login')
      end
    end
  end

  def get_content_page
    @content_page = ContentPage.find_by_url(params[:controller], params[:action])
  end

  def random_string(n=6)
    out = []
    for i in 0..n
      out << (65 + rand(26) + (32 * rand(2))).chr
    end
    out.to_s
  end

  def update_current_admin
    Admin.current = session[:admin_id]
  end

  def current_cart
    if session[:cart_id]
      if Cart.exists?(session[:cart_id])
        cart ||= Cart.find(session[:cart_id])
          session[:cart_id] = nil if (cart.purchased_at || cart.payment_notification != nil)
      else
        session[:cart_id] = nil
      end
    end
    if session[:cart_id].nil?
      cart = Cart.create!
      session[:cart_id] = cart.id
    end
    if session[:user_id]
      cart.update_attribute(:user_id, session[:user_id])
    end
    cart
  end

  def authorize_user
    unless session[:user_id]
      flash[:notice] = 'You must login to view this page.'
      redirect_to :controller => :user, :action => :login
      return
    end
    @current_user = User.find(session[:user_id])
    unless @current_user
      flash[:notice] = 'Your login has may have expired - please login again.'
      redirect_to :controller => :user, :action => :login
    end
  end

  helper_method :current_user, :current_user?

  def current_user
    if session[:user_id] && User.find(session[:user_id])
      User.find(session[:user_id])
    else
      nil
    end
  end
  def current_user?
    !current_user.nil?
  end


  def find_picture_changes(object, params)
    pictures = ''
    params.each_pair do |key,value|
      if key.to_s.include?('picture') && key.to_s.include?('_file_data')
        if value.to_s.strip != ''
          picture_id = eval("object.#{key.gsub('_file_data', '')}.id")
          pictures += ",#{picture_id}"
          logger.info picture_id
        end
      end
    end
    return pictures
  end

end
