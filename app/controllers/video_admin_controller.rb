class VideoAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :video_admin_list
    update_session
    @videos, @video_pages = Video.paginate_and_order(session[@list_name])
  end

  def pending_list
    @list_name = :video_admin_list
    update_session
    @videos, @video_pages = Video.paginate_and_order(session[@list_name].merge(:conditions => 'videos.display = 0'))
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

  def edit

    @video = Video.find(params[:id])
    if request.post?
      if @video.update_attributes(params[:video])
        flash[:notice] = "The video was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that video."
        flash[:error_field] = :video
      end
    end
  end

  def delete
    @video = Video.find(params[:id])
    if @video.destroy
      flash[:notice] = "That video was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that video."
    end
    redirect_to :action => 'list'
  end

  def new
    @video = Video.new

    if request.post?

      @video = Video.new(params[:video])
      if @video.save
        flash[:notice] = 'The video has been successfully uploaded.'
        redirect_to :action => :list
      else
        flash[:notice] = 'Sorry, there was a problem uploading this video.'
        flash[:error_field] = :video
      end
    end
  end


end
