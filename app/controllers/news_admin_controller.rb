class NewsAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :story_admin_list
    update_session
    @stories, @story_pages = Story.paginate_and_order(session[@list_name])
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
      @story = Story.new
    else
      @story = Story.new(params[:story])
      if @story.save
        flash[:notice] = "The story was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that story."
        flash[:error_field] = :story
      end
    end
  end

  def edit

    @story = Story.find(params[:id])
    if request.post?
      if @story.update_attributes(params[:story])
        flash[:notice] = "The story was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that story."
        flash[:error_field] = :story
      end
    end
  end

  def delete
    @story = Story.find(params[:id])
    if @story.destroy
      flash[:notice] = "That story was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that story."
    end
    redirect_to :action => 'list'
  end


end
