class ImageController < ApplicationController
  layout 'popup'
  def index
    @picture = Picture.find(params[:id])
    # redirect_to @picture.url(params[:width].to_i, params[:height].to_i)
    # raise @picture.to_yaml
    @file = @picture.resize(params[:width].to_i, params[:height].to_i, :file_path => true)
    send_file(@file, :filename => @file.split('/').last, :disposition => 'inline', :type => "image/#{@picture.content_type}")
  end

  def dialog
    if params[:tags] && params[:tags] != "ALL"
      @pictures = Picture.find_tagged params[:tags]
    else
      @pictures = Picture.all
    end
  end

  def upload
    unless request.post?
      @picture = Picture.new
    else
      @picture = Picture.create(params[:picture])
      redirect_to :action => :dialog
    end
  end

  def insert
    @picture = Picture.find(params[:id])
  end

end
