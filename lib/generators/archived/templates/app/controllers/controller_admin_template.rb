class <%= controller_name %>AdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :<%= file_name %>_admin_list
    update_session
    @<%= file_name.pluralize %>, @<%= file_name %>_pages = <%= class_name %>.paginate_and_order(session[@list_name])
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
      @<%= file_name %> = <%= class_name %>.new
    else
      @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
      if @<%= file_name %>.save
        flash[:notice] = "The <%= file_name %> was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that <%= file_name %>."
        flash[:error_field] = :<%= file_name %>
      end
    end
  end

  def edit

    @<%= file_name %> = <%= class_name %>.find(params[:id])
    if request.post?
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = "The <%= file_name %> was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that <%= file_name %>."
        flash[:error_field] = :<%= file_name %>
      end
    end
  end

  def delete
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    if @<%= file_name %>.destroy
      flash[:notice] = "That <%= file_name %> was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that <%= file_name %>."
    end
    redirect_to :action => 'list'
  end


end
