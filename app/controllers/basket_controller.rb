class BasketController < ApplicationController

  layout 'web'

  before_filter :prevent_problems, :only => [:confirm, :card_payment, :cash_payment_preview, :payment_confirm, :extras]
  before_filter :initialize_basket, :only => [:book, :show]
  before_filter :set_user, :only => [:confirm]
  before_filter :authorize, :only => [:part_payment]

  def prevent_problems
    unless @current_basket
      redirect_to root_url
    end
  end

  def set_user
    unless session[:user_id]
      flash[:notice] = 'Please login or sign up to continue placing your order'
      session[:checking_out] = true
      redirect_to :controller => :user, :action => :login
      return
    end
    @current_user = User.find(session[:user_id])
    unless @current_user
      flash[:notice] = 'Your login has may have expired - please login again.'
      session[:checking_out] = true
      redirect_to :controller => :user, :action => :login
      return
    end
    @current_basket.user = @current_user
    @current_basket.save
  end

  def show
    @trips = @current_basket.basket_items.collect{|x| x.trip}.uniq
  end

  def confirm
    @trips = @current_basket.basket_items.collect{|x| x.trip}.uniq
  end

  def book
    if Trip.exists?(params[:trip_id])
      @trip = Trip.find(params[:trip_id])
    else
      flash[:error] = "Sorry, we can't seem to find the details about that trip"
      return
    end
    if @trip.pickup_dropoff_times.length < 1
      flash[:error] = "Sorry, this trip isn't ready to be booked yet, check back soon!"
      redirect_to :controller => "trip", :action => "show", :id => @trip.id
      return
    end
  end

  def book_post
    if Trip.exists?(params[:trip_id])
      @trip = Trip.find(params[:trip_id])
    else
      flash[:error] = "Sorry, we can't seem to find the details about that trip"
      return
    end

    # check that they havnt asked for no bookings
    if params[:male_bookings] == "0" && params[:female_bookings] == "0"
      flash[:error] = "Hmmm... you may want to select the number of people you want to book on this trip..."
    #check that there are places left (factors in what they asked for, whats they have in basket and what is already booked)
    elsif @trip.bookable?(params[:male_bookings].to_i, params[:female_bookings].to_i)
      # build empty bookings for the basket
      params[:male_bookings].to_i.times do
        BasketItem.create!(:basket_id => @current_basket.id, :gender => "Male", :trip_id => @trip.id)
      end
      params[:female_bookings].to_i.times do
        BasketItem.create!(:basket_id => @current_basket.id, :gender => "Female", :trip_id => @trip.id)
      end
      @current_basket.save
      redirect_to :controller => "basket", :action => "bookings"
      return
    else
      flash[:error] = "Sorry, there aren't enough places left on this trip to fill this booking.  "
    end
    redirect_to :action => "book", :male_bookings => params[:male_bookings], :female_bookings => params[:female_bookings], :trip_id => params[:trip_id]
  end

  def bookings
    @basket = @current_basket
    if request.post?
      if @basket.update_attributes(params[:basket])
        if @basket.enough_pick_up_places?
          flash[:notice] = "Booking(s) added!"
          redirect_to :action => "show"
        else
          flash[:error] = "There are not enough places left for the pick-up points selected"
        end
      else
        # since there are not validations this should't really ever get hit
        flash[:problem] = "Ops - there was a problem adding that booking information, please try again"
      end
    end
  end

  def booking
    @basket_item = BasketItem.find(params[:id])
    unless @basket_item.basket == @current_basket
      flash[:error] = "You do not have permission to view this content"
      redirect_to :action => "show"
    end
    if request.post?
      params[:basket_item][:product_ids] ||= []
      if @basket_item.update_attributes(params[:basket_item])
        flash[:notice] = "Booking updated"
        redirect_to :action => "show"
      else
        flash[:error] = "There was a problem updating that booking"
      end
    end
  end

  def destroy_basket_item
    @basket_item = BasketItem.find(params[:id])
    unless @basket_item.basket == @current_basket
      flash[:error] = "You do not have permission to view this content"
      redirect_to :action => "show"
    end
    @basket_item.destroy
    flash[:notice] = "Booking removed"
    redirect_to :action => "show"
  end

  def card_payment
    # since they have got this far increase the time it will take the cart to expire so they have a chance to pay
    @current_basket.update_attribute(:expiry_time, Time.now + 60 * 60)
    redirect_to @current_basket.paypal_url(
      url_for(:controller => :basket, :action => :result, :basket_id => @current_basket.id, :only_path => false),
      url_for(:controller => :payment_notification, :action => :create, :only_path => false)
      )
  end

  def payment_confirm
    if request.post?
      unless params[:terms_and_conditions] == "1"
        flash[:error] = "You must accept the terms and conditions before we can place your order"
        redirect_to :action => "confirm", :notes => params[:notes]
      else
        @current_basket.update_attribute(:notes, params[:notes])
        if params[:card]
          redirect_to :action => "card_payment"
        elsif params[:cash]
          redirect_to :action => "offline_payment_preview"
        elsif params[:free]
          redirect_to :action => "free_trip"
        elsif params[:admin]
          redirect_to :action => "part_payment"
        end
      end
    end
  end

  def offline_payment_preview
  end

  def free_trip
    if @current_basket
      @order = @current_basket.convert_to_booking(:booking_type => "free", :booking_status => "paid")
      basket_id = @current_basket.id
      @current_basket.destroy
      redirect_to :controller => :basket, :action => :result, :basket_id => basket_id
    else
      render :text => "You have already picked a payment method, you cannot alter this order basket now."
    end
  end

  def offline_payment_execute
    if @current_basket
      @order = @current_basket.convert_to_booking(:booking_type => "cash", :booking_status => "pending")
      @current_basket.destroy
      #redirect_to :action => "offline_payment", :id => @order.id
      redirect_to :action => 'result'
    else
      render :text => "You have already picked a payment method, you cannot alter this order basket now."
    end
  end

  def offline_payment
    @order = Booking.find(params[:id])
  end

  def part_payment
    if request.post?
      if params[:amount].to_f < 0 || params[:amount].to_f > @current_basket.total
        flash[:error] = "Please enter a valid amount"
      else
        flash[:notice] = "Booking Added"
        admin = Admin.find(session[:admin_id])
        @current_basket.convert_to_booking(:booking_type => "admin - #{admin.name}", :amount => params[:amount])
        @current_basket.destroy
        @current_basket = nil
        redirect_to :controller => "booking_admin", :action => "list_bookings"
      end
    end
  end

  def extras
    if params[:deposit] == "true"
      @current_basket.update_attributes(:deposit => true)
    elsif params[:deposit] == "false"
      @current_basket.update_attributes(:deposit => false)
    end
    @products = @current_basket.trips.collect{|x| x.products}.flatten.uniq
    if @products.length < 1
      redirect_to :action => "confirm"
    end
  end

  def set_extras
    for basket_item in @current_basket.basket_items
      params[:basket_items] ||= {}
      params[:basket_items][basket_item.id.to_s] ||= {}
      params[:basket_items][basket_item.id.to_s][:product_ids] ||= {}
      ids = []
      for product_id in params[:basket_items][basket_item.id.to_s][:product_ids]
        ids << product_id[0].to_i
      end
      basket_item.update_attribute(:product_ids, ids)
    end
    redirect_to :action => "confirm"
  end

  def result
    redirect_to :controller => 'booking', :action => 'result'
    #redirect_to :controller => "user", :action => "bookings"
  end

end
