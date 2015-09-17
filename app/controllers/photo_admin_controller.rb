class PhotoAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :photo_admin_list
    update_session
    @photos, @photo_pages = Photo.paginate_and_order(session[@list_name])
  end
  
  def pending_list
    @list_name = :photo_admin_list
    update_session
    @photos, @photo_pages = Photo.paginate_and_order(session[@list_name].merge(:conditions => 'photos.display=0'))
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


  def new
    if request.get?
      @photo = Photo.new
    else
      @photo = Photo.new(params[:photo])
      if @photo.save
        flash[:notice] = "The photo was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that photo."
        flash[:error_field] = :photo
      end
    end
  end

  def edit

    @photo = Photo.find(params[:id])
    if request.post?
      if @photo.update_attributes(params[:photo])
        flash[:notice] = "The photo was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that photo."
        flash[:error_field] = :photo
      end
    end
  end

  def delete
    @photo = Photo.find(params[:id])
    if @photo.destroy
      flash[:notice] = "That photo was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that photo."
    end
    redirect_to :action => 'list'
  end


end
