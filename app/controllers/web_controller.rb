class WebController < ApplicationController

  before_filter :get_content_page, :only => [:home, :about_us]

  def contact
    @site_profile = SiteProfile.first
  end

  def contact_recieved
    Mailer.deliver_contact_recieved(params[:customer])
    redirect_to :action => 'thank_you'
  end

  def index
    #if request.post?
    #  redirect_to "/#{params[:university]}"
    #end

    @banners = BenefitBanner.past_random(8)
    @university_logos = nil

    @trip_groups    = TripGroup.find(:all)

    @national_trips = Trip.all(:conditions => ["trips.display = ? AND trips.start_date >=? AND trips.highlight = ?", true, Date.today, true], :order => :start_date, :limit => 1)

    @all_trips = Trip.all(:conditions => ["trips.display = ? AND trips.start_date >=? AND trips.highlight = ?", true, Date.today, true], :order => :start_date)

    @universities = University.all(:conditions => {:display => true}, :order => :name)
  end

  def welcome
    if request.post?
      if params[:promo_code].blank?
        flash.now[:error] = "Please enter a promo code."
      elsif params[:email].blank?
        flash.now[:error] = "Please enter your email so we can let you know when this offer is active."
      else
        Mailer.deliver_welcome(params[:email], params[:promo_code])
        @thank_you = true
      end
    end
  end

  def past_trips
    @banners = BenefitBanner.past_random(8)
    @flags = Flag.all
    @grouped_flags = @flags.in_groups_of(8, false)
    if !params[:trip].blank? && Trip.exists?(params[:trip])
      @trip = Trip.find(params[:trip])
      @trip_id = @trip.id
    end
    if !params[:destination].blank? && Destination.exists?(params[:destination])
      @destination = Destination.find(params[:destination])
      @destination_id = @destination.id
    end

  end

  def universities
    @banners = BenefitBanner.univ_random(8)
    @flags = Flag.all
    @number_displayed = 8
    if !params[:trip].blank? && Trip.exists?(params[:trip])
      @trip = Trip.find(params[:trip])
      @trip_id = @trip.id
    end
    if !params[:destination].blank? && Destination.exists?(params[:destination])
      @destination = Destination.find(params[:destination])
      @destination_id = @destination.id
    end
  end

  def reserve_post
    if params[:male_bookings].to_i < 1 && params[:female_bookings].to_i < 1
      flash[:error] = "Oops, you may want to tell us how many places you wanted to enquire about booking on that trip"
    elsif params[:name].blank?
      flash[:error] = "Please enter your name so we can get back to you"
    elsif params[:phone].blank? && params[:email].blank?
      flash[:error] = "Please enter your either your email address or a contact phone number so that we can get in touch with you"
    else
      Reservation.create!(:name => params[:name], :email => params[:email], :telephone => params[:phone], :male => params[:male_bookings], :female => params[:female_bookings], :trip => Trip.find(params[:trip]).name_dates)
      Mailer.deliver_reserve(params)
      redirect_to :controller => "web", :action => "thank_you_reserve"
      return
    end
    render :action => "reserve"
  end

  def win
    render :layout => false
  end

  def cheap_train_tickets
    render :layout => false
  end

  def download_mini_guides
    #if request.referer and URI(request.referer).path.include?("/university_contacts")
      #show download page
    #else
    #  redirect_to new_university_contact_path
    #end
  end

end
