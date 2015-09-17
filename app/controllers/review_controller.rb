class ReviewController < ApplicationController

  layout "web"
  
  before_filter :authorize_user, :only => [:upload]

  def index
    redirect_to :action => 'upload'
  end

  def upload 
    @review = Review.new
    @trips = Trip.find(:all, :conditions => ["display=1 AND start_date < ?", Date.today])
    
    if request.post?
      @review = Review.new(params[:review])
      @review.user_id = session[:user_id]
      @review.display = 0
      if @review.save
        flash[:title] = 'Thank You!'
        flash[:notice] = 'Thanks for uploading your review, it will be reviewed as soon as possible before it is visible on the site'
      else 
        flash[:notice] = 'There was a problem uploading that review.'
        flash[:error_field] = :review
      end
    end
  end

end
