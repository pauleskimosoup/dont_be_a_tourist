class NewsController < ApplicationController

  layout "web"

  def index
    session[:news] ||= { }
    session[:news][:tag] = nil
    session[:news][:month] = nil
    redirect_to :action => 'list'
  end

  def init_year
    @months = []
    @year = params[:year].to_i || Date.today.year
    last = 12
    last = Date.today.month unless @year != Date.today.year
    for month in (0 ... last)
      @months << [month, Story.count(:conditions => ["month(date) = #{month+1} and year(date) = #{@year}"])]
    end
    @months.reverse!
  end

  def ajax_year
    init_year
    render(:layout => false)
  end


  def init_navigation
    session[:news] ||= { }
    @tags = Story.all_tags_array.sort
    init_year
    @years = []
    earliest = Story.find(:first, :order => "date asc")
    if earliest
      first_year = (earliest.date && earliest.date.year) || earliest.created_at.year
      for year in (first_year .. Date.today.year)
        @years << year
      end
      @years.reverse!
    end
  end

  def list
    init_navigation
    session[:news][:tag] = params[:tag] if params[:tag]
    if params[:month]
      session[:news][:month] = params[:month]
      session[:news][:tag] = nil
    end
    if session[:news][:tag]
      @stories = Story.find_tagged(session[:news][:tag]).all(:order => 'date desc')
      @list_name = session[:news][:tag]
    else
      if session[:news][:month]
        params[:year] ||= Date.today.year
        @stories = Story.all_from_date(session[:news][:month].to_i + 1, params[:year])
      else
        @stories = Story.find_recent(10)
        @list_name = "Latest Headlines"
      end
    end
    @stories, @story_pages = Pager.pages(@stories, params[:page] || 1, 10)
  end

  def show
    @story = Story.find(params[:id])
    unless @story.display?
      redirect_to :action => 'list'
    end
    params[:year] = @story.date && @story.date.year
    init_navigation
  end

end
