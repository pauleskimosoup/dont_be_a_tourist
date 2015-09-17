class BookingAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @booking = Booking.find(params[:id])
    @list_name = :booking_admin_list
    update_session
    @bookings, @booking_pages = BookingItem.paginate_and_order(session[@list_name].merge(:conditions => "bookings.id = #{@booking.id}"))

    if request.post?
      old_payment_recieved = @cart.payment_recieved
      new_payment_recieved = params[:cart][:payment_recieved]
      if @cart.update_attributes(params[:cart])
        #raise params.to_yaml
        if (old_payment_recieved.to_s == 'false') && (new_payment_recieved.to_s == 'true')
          Mailer.deliver_payment_recieved_notice(@cart.id)
        end
        flash[:notice] = "The booking was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem updating that booking."
        flash[:error_field] = :trip_instance
      end
    end
  end

  def list_bookings
    @list_name = :list_booking_admin_list
    update_session
    @bookings, @booking_pages = Booking.paginate_and_order(session[@list_name])
  end

  def pending_list
    @list_name = :list_pending_booking_admin_list
    update_session
    @bookings, @booking_pages = Booking.paginate_and_order(session[@list_name].merge(:conditions => "booking_status = 'pending' OR outstanding_balance > 0"))
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

  def update
    @booking = Booking.find(params[:id])
    if @booking.update_attributes(params[:booking])
      flash[:notice] = "Note Updated"
      redirect_to :action => "list", :id => @booking.id
    else
      flash[:error] = "Problem Updating Note"
      redirect_to :action => "list", :id => @booking.id
    end
  end

  def delete
    @booking = Cart.find(params[:id])
    if @booking.destroy
      flash[:notice] = "That booking was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that booking."
    end
    redirect_to :action => 'pending_list'
  end

  def edit
    @booking_item = BookingItem.find(params[:id])
    if request.post?
      if @booking_item.update_attributes(params[:booking_item])
        flash[:notice] = "The booking was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem updating that booking."
        flash[:error_field] = :booking_item
      end
    end
  end

  def cancel_with_email
    @booking = Booking.find(params[:id])
    begin
      Mailer.deliver_booking_cancelled_notice(@booking.id)
    rescue
    end
    @booking.cancel!
    redirect_to :action => "list_bookings"
  end

  def cancel_without_email
    @booking = Booking.find(params[:id])
    @booking.cancel!
    redirect_to :action => "list_bookings"
  end

  def confirm
    @booking = Booking.find(params[:id])
    @booking.update_attributes(:booking_status => "paid", :outstanding_balance => 0)
    Mailer.deliver_payment_recieved_notice(@booking.id)
    redirect_to :action => "list", :id => @booking.id
  end

  def resend_payment_confirmation
    @booking = Booking.find(params[:id])
    Mailer.deliver_payment_recieved_notice(@booking.id)
    flash[:notice] = "Payment Confirmation Resent"
    redirect_to :action => "list", :id => @booking.id
  end

  def make_payment
    @booking = Booking.find(params[:id])
    if request.post?
      if params[:amount].to_f > 0
        @booking.update_attributes(:booking_status => "pending", :outstanding_balance => @booking.outstanding_balance - params[:amount].to_f)
        if params[:email] == "1"
          Mailer.deliver_deposit_update(@booking.id)
        end
        redirect_to :action => "list", :id => @booking.id
      else
        flash[:error] = "Invalid amount"
        render :action => "make_payment"
      end
    end
  end

  def send_payment_reminder
    @booking = Booking.find(params[:id])
    Mailer.deliver_admin_payment_reminder(@booking.id)
    flash[:notice] = "Email Sent"
    redirect_to :action => "list", :id => @booking.id
  end

  def remove_product
    booking = BookingItem.find(params[:booking_id])
    booking.update_attribute(:product_ids, booking.product_ids.delete(params[:product_id]))
    redirect_to :action => "edit", :id => booking.id
  end

end
