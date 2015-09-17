class AccommodationAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => "list"
  end

  def list
    @accommodations = Accommodation.find(:all, :order => (params[:order] ||= :name))
    @accommodations, @accommodations_pages = Pager.pages(@accommodations, params[:page], 100)
  end

  def new
    @accommodation = Accommodation.new
  end

  def edit
    @accommodation = Accommodation.find(params[:id])
  end

  def create
    @accommodation = Accommodation.new(params[:accommodation])

    if @accommodation.save
      redirect_to(:action => "list", :notice => 'Accommodation was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @accommodation = Accommodation.find(params[:id])


    if @accommodation.update_attributes(params[:accommodation])
      redirect_to(:action => "list", :notice => 'Accommodation was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def delete
    @accommodation = Accommodation.find(params[:id])
    @accommodation.destroy
    redirect_to(:controller => "accommodations_admin", :action => "index")
  end
end