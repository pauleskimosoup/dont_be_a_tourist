class PictureController < ApplicationController

  def master_crop
    unless params[:picture_ids]
      redirect_to :back
      return
    end
      picture_ids = params[:picture_ids].split(',').reject!{|x| x == ''}
      if picture_ids == nil
        if params[:return_url]
          redirect_to params[:return_url]
        else
          redirect_to :controller => :admin, :action => :index
        end
        return
      end
      pictures = []
      for id in picture_ids
        pictures << Picture.find(id)
      end
      render :partial => 'picture/master_crop', :collection => pictures, :layout => 'admin'
    if request.post?
      picture = Picture.find(params[:picture_id])
      picture.crop_master(params)
    end
  end

  def crop
    picture = Picture.find(params[:id])
    crop = params[:crop] || 1
    if request.post?
      unless params[:commit].to_s.downcase == 'cancel'
        picture.crop(params)
      end
        redirect_to :controller => params[:owner_type].capitalize, :action => :edit, :id => params[:owner_id]
        return
    end
    render :partial => 'picture/crop', :locals => {:picture => picture, :width => params[:width], :height => params[:height], :crop => crop}
  end

  def edit
    render :partial => 'picture/done'
  end

end