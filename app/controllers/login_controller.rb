class LoginController < ApplicationController


  before_filter :authorize, :except => [ :index, :login, :forgotten, :logout]

  layout "admin"

  def index
    redirect_to :action => 'login'
  end

  def add_demo_admin
    newpass = random_string
    params[:admin][:password] = newpass
    params[:admin][:password2] = newpass
    @admin = Admin.new(params[:admin])
    @admin.permissions = "all"
    @admin.email = @admin.name
    if @admin.save
      Mailer.deliver_welcome_admin(@admin, newpass)
      Mailer.deliver_new_admin(@admin)
      flash[:notice] = "An email has been sent with your new password."
      #flash[:notice] = "An email has been sent with your new password, which is " + newpass
      redirect_to :controller => 'login', :action => 'login'
    else
      flash[:notice] = "Sorry, there was a problem creating your account. That email address might already be registered. If you have forgotten your password, please click the link below."
      redirect_to :controller => 'login', :action => 'login'
    end
  end

  def login
    if request.get?
      session[:admin_id] = nil
      @admin = Admin.new
    else
      @admin = Admin.new(params[:admin])
      logged_in_admin = @admin.try_to_login
      if logged_in_admin
        session[:admin_id] = logged_in_admin.id
        redirect_to(:controller => 'login', :action => 'home')
      else
        flash[:notice] = "There was a problem logging in. Please check your admin name and password."
      end
    end
  end

  def logout
    session[:admin_id] = nil
    redirect_to(:controller => 'login', :action => 'login')
  end

  def forgotten
    if request.post?
      @admin = Admin.find(:first,
                        :conditions => ["name = ?", params[:admin][:name]])
      if @admin
        newpass = random_string
        @admin.password = newpass
        @admin.password2 = newpass
        @admin.save
        Mailer.deliver_forgotten_password(@admin, newpass)
        flash[:notice] = "Your new password has been sent to you. As soon as you recieve it you can log in."
        redirect_to :action => 'login'
      else
        flash[:notice] = "We don't have a record of that admin name. Please check and try again."
      end
    end
  end


end
