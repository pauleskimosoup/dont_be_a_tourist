class ContentPageAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :content_page_admin_list
    update_session
    @content_pages, @content_page_pages = ContentPage.paginate_and_order(session[@list_name])
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
      @content_page = ContentPage.new
    else
      @content_page = ContentPage.new(params[:content_page])
      if @content_page.save
        flash[:notice] = "The content_page was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that content_page."
        flash[:error_field] = :content_page
      end
    end
  end

  def edit

    @content_page = ContentPage.find(params[:id])
    if request.post?
      if @content_page.update_attributes(params[:content_page])
        flash[:notice] = "The content_page was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that content_page."
        flash[:error_field] = :content_page
      end
    end
  end

  def delete
    @content_page = ContentPage.find(params[:id])
    if @content_page.destroy
      flash[:notice] = "That content_page was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that content_page."
    end
    redirect_to :action => 'list'
  end


end
