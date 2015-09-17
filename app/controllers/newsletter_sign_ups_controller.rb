class NewsletterSignUpsController < ApplicationController

  layout "web"

  def new
    @newsletter_sign_up = NewsletterSignUp.new
    get_universities
  end

  def create
    @newsletter_sign_up = NewsletterSignUp.new(params[:newsletter_sign_up])

    if @newsletter_sign_up.valid?
      NewsletterSignUpMailer.deliver_new_sign_up(@newsletter_sign_up)
      # send email
      flash[:notice] = "Thank you for submitting your details"
      redirect_to :controller => "web", :action => "index"
    else
      render :action => 'new'
    end
  end
end