class SplashPageAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :splash_page_admin_list
    update_session
    @splash_pages, @splash_page_pages = SplashPage.paginate_and_order(session[@list_name])
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
      @splash_page = SplashPage.new
    else
      @splash_page = SplashPage.new(params[:splash_page])
      if @splash_page.save
        flash[:notice] = "The story was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that splash page."
        flash[:error_field] = :splash_page
      end
    end
  end

  def edit
    @splash_page = SplashPage.find(params[:id])
    if request.post?
      params[:splash_page][:promo_code_ids] ||= []
      if @splash_page.update_attributes(params[:splash_page])
        flash[:notice] = "The splash page was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that splash page."
        flash[:error_field] = :splash_page
      end
    end
  end

  def delete
    @splash_page = SplashPage.find(params[:id])
    if @splash_page.destroy
      flash[:notice] = "That splash page was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that splash page."
    end
    redirect_to :action => 'list'
  end


end
