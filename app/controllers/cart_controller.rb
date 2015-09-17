class CartController < ApplicationController

  layout 'web'

  before_filter :authorize_user, :only => [:payment]

  def index
    redirect_to :action => :show
  end

  def result
    @cart = Cart.find(params[:invoice].gsub("es","").to_i)
    #@cart = Cart.find(params[:cart_id])
  end

  def show
    @cart = current_cart
  end

  def show_more
    respond_to do |type|
      type.js {
        render :update do |page|
          page["trip_instance_#{params[:trip]}"].toggle
          page["trip_instance_#{params[:trip]}_more_button"].toggle
          page["trip_instance_#{params[:trip]}_less_button"].toggle
        end
      }
    end
  end

  def user
    if session[:user_id]
      redirect_to :action => :payment
      return
    end

    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      @user.how_did_you_hear = params[:other] if params[:other].to_s.strip != ''
      if @user.save
        flash[:notice] = "Your account was successfully added."
        session[:user_id] = @user.id
        redirect_to :action => :payment
      else
        flash[:notice] = "Sorry, there was a problem creating that user."
        flash[:error_field] = :user
      end
    end
  end

  def update_notes
      redirect_to :controller => :cart, :action => :user
  end

  def payment
    @cart = current_cart
    unless @cart.update_attribute(:user_id, session[:user_id])
      flash[:title] = 'Sorry'
      flash[:notice] = 'Something went wront while updating your cart.'
    end
    @user = User.find(session[:user_id])
  end

  def payment_live
    @cart = current_cart
    unless @cart.update_attribute(:user_id, session[:user_id])
      flash[:title] = 'Sorry'
      flash[:notice] = 'Something went wront while updating your cart.'
    end
    @user = User.find(session[:user_id])
  end

  def billing_address
    @cart = current_cart
    @user = User.find(session[:user_id])

    if request.post?
      @cart.update_attribute(:notes, params[:notes])
      unless params[:agree] == '1'
        flash[:notice] = 'Your must agree to the terms and conditions.'
        return
      end
      if params[:spoof] == 'true'
        redirect_to :controller => :payment_notification, :action => :spoof, :cart_id => @cart.id
      else
        if @user.email == "bolt.shadow@gmail.com"
          redirect_to @cart.paypal_url(url_for(:controller => :cart, :action => :result, :cart_id => @cart.id, :only_path => false), url_for(:controller => :payment_notification, :action => :create, :only_path => false), true)
        else
          redirect_to @cart.paypal_url(url_for(:controller => :cart, :action => :result, :cart_id => @cart.id, :only_path => false), url_for(:controller => :payment_notification, :action => :create, :only_path => false), false)
        end
      end
    end
  end

  def offline_payment_info
    @cart = current_cart
    if @cart.trip_instances.length < 1
      flash[:title] = 'Sorry'
      flash[:notice] = 'You can\'t view this page with no items in your cart.'
      redirect_to :controller => :web, :action => :notice
      return
    end

    if request.post?
      unless params[:agree] == '1'
      flash[:notice] = 'You must agree to the terms and conditions.'
      return
    end
      @cart.update_attribute :notes, params[:notes]
      redirect_to :controller => :cart, :action => :book
    end
  end

  def offline_payment
    @cart = Cart.find(params[:cart])
  end

  def book
    @cart = current_cart
    if @cart.trip_instances.length < 1
      flash[:title] = 'Sorry'
      flash[:notice] = 'You can\'t view this page with no items in your cart.'
      redirect_to :controller => :web, :action => :notice
      return
    end
    @cart.convert_to_booking
    for trip_instance in @cart.trip_instances
      trip_instance.trip.update_attribute(:places, trip_instance.trip.places-1)
    end
    Mailer.deliver_prelim_booking_info(@cart.id)
    Mailer.deliver_prelim_booking_notice(@cart.id)
    redirect_to :controller => :cart, :action => :offline_payment, :cart => @cart.id
  end

end
