class UserAdminController < ApplicationController

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
    @list_name = :user_admin_list
    update_session
    @users, @user_pages = User.paginate_and_order(session[@list_name])
  end

  def new
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      @user.how_did_you_hear = params[:other] if params[:other].to_s.strip != ''
      if @user.save
        flash[:notice] = "The user was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that user."
        flash[:error_field] = :user
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    if request.post?
      if @user.update_attributes(params[:user])
        @user.how_did_you_hear = params[:other] if params[:other].to_s.strip != ''
        @user.save
        flash[:notice] = "The user was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem updating that user."
        flash[:error_field] = :user
      end
    end
  end

  def delete
    user = User.find(params[:id])
    if user.destroy
      flash[:notice] = "That user was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that user."
    end
    redirect_to :action => 'list'
  end
  
  def newsletter_list
    emails = User.find_all_by_newsletter(true).collect{|x| x.email}
    emails.uniq!
    @emails = emails.join(', ')
  end
  
  def reset_password
    user = User.find(params[:id])
    flash[:notice] = "User password reset and email sent"
    new_password = user.reset_password
    Mailer.deliver_user_welcome_and_details(user, new_password)
    redirect_to :action => "edit", :id => user.id
  end
  
  def sign_in_as_user
    @user = User.find(params[:id])
    session[:user_id] = @user.id
    flash[:notice] = "Signed in as #{@user.name}.  Go to the front end of the site to book trips as this user or view their booking history."
    redirect_to :controller => "user_admin", :action => "list"
  end

end 
