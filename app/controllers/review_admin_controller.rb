class ReviewAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :review_admin_list
    update_session
    @reviews, @review_pages = Review.paginate_and_order(session[@list_name])
  end

  def pending_list
    @list_name = :review_admin_list
    update_session
    @reviews, @review_pages = Review.paginate_and_order(session[@list_name].merge(:conditions => 'reviews.display = 0'))
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
    @review = Review.new

    if request.post?
      @review = Review.new(params[:review])
      if @review.save
        flash[:notice] = 'The review has been successfully uploaded.'
        redirect_to :action => :list
      else
        flash[:notice] = 'Sorry, there was a problem uploading this review.'
        flash[:error_field] = :review
      end
    end
  end

  def edit
    @review = Review.find(params[:id])
    if request.post?
      if @review.update_attributes(params[:review])
        flash[:notice] = "The review was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that review."
        flash[:error_field] = :review
      end
    end
  end

  def delete
    @review = Review.find(params[:id])
    if @review.destroy
      flash[:notice] = "That review was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that review."
    end
    redirect_to :action => 'list'
  end


end
