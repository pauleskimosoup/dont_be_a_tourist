class <%= class_name %>Controller < ApplicationController
  layout 'web'
  before_filter :authorize_<%= singular_name %>, :except => [:forgot, :login, :new]

  def authorize_<%= singular_name %>
    unless session[:<%= singular_name %>_id]
      flash[:notice] = 'You must login to view this page.'
      redirect_to :controller => :<%= singular_name %>, :action => :login
      return
    end
    @current_<%= singular_name %> = <%= class_name %>.find(session[:<%= singular_name %>_id])
    unless @current_<%= singular_name %>
      flash[:notice] = 'Your login has may have expired - please login again.'
      redirect_to :controller => :<%= singular_name %>, :action => :login
    end
  end

  def index
    redirect_to :action => :home
  end

  def home

  end

  def login
    if request.post?
      <%= singular_name %> = <%= class_name %>.login(params[:username], params[:password])
      if <%= singular_name %>
        session[:<%= singular_name %>_id] = <%= singular_name %>.id
        flash[:notice] = 'Login complete.'
        redirect_to :action => :home
      else
        flash[:notice] = 'Login failed - check your username and password.'
      end
    end
  end
  
  def logout
    session[:<%= singular_name %>_id] = nil
    redirect_to :action => :login
  end

  def forgot
    if request.post?
      <%= singular_name %> = <%= class_name %>.find_by_username(params[:username])
      if not <%= singular_name %>
        flash[:notice] = 'Could not find your login information - check your username.'
        return
      end
      new_password = <%= singular_name %>.reset_password
      <%= class_name %>Mailer.deliver_forgotten_password(<%= singular_name %>, new_password)
      flash[:notice] = 'Your password has been reset and your login details have been emailed to you.'
    end 
  end
  
  def new
    if request.get?
      @<%= singular_name %> = <%= class_name %>.new
    else
      @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
      if @<%= singular_name %>.save
        flash[:notice] = "The <%= singular_name %> was successfully added."
        session[:<%= singular_name %>_id] = @<%= singular_name %>.id
        redirect_to :action => 'home'
      else
        flash[:notice] = "Sorry, there was a problem creating that <%= singular_name %>."
        flash[:error_field] = :<%= singular_name %>
      end
    end
  end

  def edit
    @<%= singular_name %> = <%= class_name %>.find(session[:<%= singular_name %>_id])
    if request.post?
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "Your details were updated successfully."
      else
        flash[:notice] = "Sorry, there was a problem updating your details."
        flash[:error_field] = :<%= singular_name %>
      end
    end
  end

end
