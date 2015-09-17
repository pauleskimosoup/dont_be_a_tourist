class FeedbacksController < ApplicationController

  layout 'web'

  def create
    @feedback = Feedback.new(params[:feedback])
    if @feedback.valid?
      Mailer.deliver_feedback(@feedback.message)
      flash[:notice] = 'Feedback sent'
    end
    render :template => 'booking/result'
  end

end