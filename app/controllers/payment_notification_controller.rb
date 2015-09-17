class PaymentNotificationController < ApplicationController

   protect_from_forgery :except => [:create, :complete_payment]

  def create
    logger.info "PAYMENT NOTIFICATION ACTIVITY"
    if params[:invoice].blank?
      logger.info "NO INVOICE IN PARAMS FROM PAYPAL - LIKELY A MANUAL INVOICE SENT OUT THROUGH PAYPAL NOT THE WEBSITE."

    else

      basket_id = params[:invoice].gsub("dbat","").to_i
      logger.info "RELATED TO BASKET #{basket_id}"
      basket = Basket.find(:first, :conditions => ["id = ?", basket_id])

      # check that the cart total is what they have paid
      #unless basket.total == params["mc_gross"].to_f
      #  Mailer.deliver_payment_problem(basket, "basket price differs from price paid")
      #  render :nothing => :true
      #  return
      #end

      # check that there isnt already a booking related to that cart, if there is modify that, else create on
      if Booking.find(:first, :conditions => ["basket_id = ?", basket_id])
        booking = Booking.find(:first, :conditions => ["basket_id = ?", basket_id])
        if params[:payment_status].to_s == 'Completed'
          booking.update_attribute(:booking_status, "paid")
          begin
            Mailer.deliver_booking_info(booking.id)
            Mailer.deliver_booking_notice(booking.id)
          rescue => e
            logger.info "#{e}"
          end
          logger.info "EXISTING BOOKING CHANGED TO PAID"
        end
     elsif basket

        if params[:payment_status].to_s == 'Completed'
    basket.convert_to_booking(:booking_type => "paypal", :booking_status => "paid")
          PaymentNotification.create!(:params => params, :booking_id => booking.id, :status => params[:payment_status], :transaction_id => params[:txn_id])
          logger.info "CREATED NEW BOOKING WITH STATUS AS PAID"
          basket.destroy

        elsif params[:payment_status].to_s == "Pending"
        basket.convert_to_booking(:booking_type => "paypal", :booking_status => "pending")
          PaymentNotification.create!(:params => params, :booking_id => booking.id, :status => params[:payment_status], :transaction_id => params[:txn_id])
          logger.info "CREATED NEW BOOKING WITH STATUS AS PENDING"
          basket.destroy

        end

      else

        logger.info "NO RELATED BOOKING OR BASKET FOUND"

      end

    end

    render :nothing => :true

 end

  def complete_payment
    logger.info "PAYMENT NOTIFICATION ACTIVITY - COMPLETE A PENDING PAYMENT"
    booking_id = params[:invoice].gsub("rp", "").to_i
    logger.info "RELATED TO BOOKING #{booking_id}"
    booking = Booking.find(booking_id)

    if params[:payment_status].to_s == 'Completed'
      booking.update_attributes(:booking_status => "paid", :outstanding_balance => 0)
      Mailer.deliver_booking_info(booking.id)
      Mailer.deliver_booking_notice(booking.id)
      logger.info "EXISTING BOOKING CHANGED TO PAID"
    elsif params[:payment_status].to_s == "Pending"
      booking.update_attribute(:booking_status => "pending")
      logger.info "EXISTING BOOKING CHANGED TO PENDING"
    end

    render :nothing => :true
  end

end
