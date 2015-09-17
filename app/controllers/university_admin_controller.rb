class UniversityAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :university_admin_list
    update_session
    @universities, @university_pages = University.paginate_and_order(session[@list_name])
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
      @university = University.new
    else
      @university = University.new(params[:university])
      if @university.save
        flash[:notice] = "The University was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that University."
        flash[:error_field] = :university
      end
    end
  end

  def edit
    @university = University.find(params[:id])
    if request.post?
      if @university.update_attributes(params[:university])
        flash[:notice] = "The University was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that University."
        flash[:error_field] = :university
      end
    end
  end

  def delete
    @university = University.find(params[:id])
    if @university.destroy
      flash[:notice] = "That University was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that University."
    end
    redirect_to :action => 'list'
  end

end
