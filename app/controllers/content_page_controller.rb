class ContentPageController < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @content_pages, @content_page_pages = ContentPage.paginate_and_order(params)
  end

  def show
    @content_page = ContentPage.find(params[:id])
  end

end
