class VideoController < ApplicationController

  layout "web"
  
  before_filter :authorize_user, :only => [:upload]

  def index
    redirect_to :action => 'upload'
  end
  
  def upload 
    @video = Video.new
    @trips = Trip.find(:all, :conditions => ["display=1 AND start_date < ?", Date.today])
    
    if request.post?
      @video = Video.new(params[:video])
      @video.user_id = session[:user_id]
      @video.display = 0
      if @video.save
        flash[:title] = 'Thank You!'
        flash[:notice] = 'Thanks for uploading your video, it will be reviewed as soon as possible before it is visible on the site'
      else 
        flash[:notice] = 'There was a problem uploading that video.'
        flash[:error_field] = :video
      end
    end
  end

end
