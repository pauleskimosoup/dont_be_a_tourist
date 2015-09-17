class UserController < ApplicationController

  layout "web"

  before_filter :authorize_user, :except => [:forgot, :login, :new]
  before_filter :authorize_specific_user => [:edit]
  
  def index
    redirect_to :action => :home
  end

  def home
    @user = @current_user
  end

  def login
    if request.post?
      user = User.login(params[:username], params[:password])
      if user
        session[:user_id] = user.id
        flash[:notice] = 'Login complete.'
        if session[:checking_out] == true
          redirect_to :controller => "basket", :action => "confirm"
          session[:checking_out] = false
          return
        end
        redirect_to :controller => "user", :action => "home"
      else
        flash[:notice] = 'Login failed - check your username and password.'
      end
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to :action => :login
  end

  def forgot
    if request.post?
      user = User.find_by_username(params[:username])
      if not user
        flash[:notice] = "Oops... we couldn't find your login information - check your email address."
        return
      end
      new_password = user.reset_password
      UserMailer.deliver_forgotten_password(user, new_password)
      flash[:notice] = 'Your password has been reset and your login details have been emailed to you.'
    end 
  end
  
  def new
    
    if request.get?
      if session[:user_id]
        redirect_to :controller => :user, :action => :home
        return
      end
      @user = User.new
    else
      @user = User.new(params[:user])
      @user.how_did_you_hear = params[:other] if params[:other].to_s.strip != ''
      if @user.save
        flash[:notice] = "Account created!"
        session[:user_id] = @user.id
        if session[:checking_out] == true
          session[:checking_out] = false
          redirect_to :controller => "basket", :action => "confirm"
          return
        end
        if @user.newsletter == 1
          require 'createsend'
          begin
            #docs http://rubydoc.info/gems/createsend/
            CreateSend.api_key '479f16bedf154612ec72e2ca1dc37ba2'
            
            #dbat new account list id
            list_id = "955695a910c3bfa3b42dcc81c2b859d6"
            
            name = "#{@user.first_name} #{@user.family_name}"
            client = CreateSend::Subscriber.add(list_id, @user.email, name, nil, false)
            
          rescue
          end
        end
        
        redirect_to :action => 'home'
      else
        flash[:error_field] = :user
      end
    end
  end

  def edit
    @user = User.find(session[:user_id])
    if request.post?
      if @user.update_attributes(params[:user])
        @user.how_did_you_hear = params[:other] if params[:other].to_s.strip != ''
        @user.save
        flash[:notice] = "Your details were updated successfully."
      else
        flash[:notice] = "Sorry, there was a problem updating your details."
        flash[:error_field] = :user
      end
    end
  end
  
  def bookings
    if request.post?
      @trip = params[:trip]
      @sharing_options = params[:sharing_options]
      @name = "#{params[:first_name]} #{params[:family_name]}"
      unless @trip.blank? || @sharing_options.blank? 
        begin
          Mailer.deliver_sharing_rooms(@name, @trip, @sharing_options)
          flash[:notice] = "Thank you.  We can't guarantee we can meet your request but we'll certainly try our best"
        rescue
          flash[:notice] = "Sorry there was a problem, please try again"
        end
      end
    end 
    @bookings = @current_user.bookings
    @trip_names = @bookings.map{|booking| booking.trips.select{|trip|  trip.start_date > (Date.today + 2)}.map{|trip| trip.name }}.flatten
  end
  
  def booking
    @booking = Booking.find(params[:id])
    unless @booking.user == @current_user
      redirect_to :back
    end
    if params[:printer_friendly] == "true"
      render :layout => false
    end
    if params[:generate_invoice] == "true"
      @booking.generate_invoice
      send_file "#{RAILS_ROOT}/public/documents/invoices/#{@booking.id}.pdf", :type => 'pdf', :filename => 'invoice.pdf'
    end
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

end
