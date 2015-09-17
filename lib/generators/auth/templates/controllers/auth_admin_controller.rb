class <%= class_name %>AdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

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

 def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :<%= singular_name %>_admin_list
    update_session
    @<%= plural_name %>, @<%= singular_name %>_pages = <%= class_name %>.paginate_and_order(session[@list_name])
  end

  def new
    if request.get?
      @<%= singular_name %> = <%= class_name %>.new
    else
      @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
      if @<%= singular_name %>.save
        flash[:notice] = "The <%= singular_name %> was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that <%= singular_name %>."
        flash[:error_field] = :<%= singular_name %>
      end
    end
  end

  def edit
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if request.post?
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "The <%= singular_name %> was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem updating that <%= singular_name %>."
        flash[:error_field] = :<%= singular_name %>
      end
    end
  end

  def delete
    <%= singular_name %> = <%= class_name %>.find(params[:id])
    if <%= singular_name %>.destroy
      flash[:notice] = "That <%= singular_name %> was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that <%= singular_name %>."
    end
    redirect_to :action => 'list'
  end

end 
