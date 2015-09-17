class PhotoController < ApplicationController

  layout "web"
  
  before_filter :authorize_user, :only => [:upload]

  def index
    redirect_to :action => 'upload'
  end

  def upload 
    @photo = Photo.new
    @trips = Trip.find(:all, :conditions => ["display=1 AND start_date < ?", Date.today])
    
    if request.post?
      @photo = Photo.new(params[:photo])
      @photo.user_id = session[:user_id]
      @photo.display = 0
      if @photo.save
        flash[:notice] = 'Thanks for uploading your photo, it will be reviewed as soon as possible before it is visible on the site'
      else 
        flash[:notice] = 'There was a problem uploading that photograph.'
        flash[:error_field] = :photo
      end
    end
  end

end