class <%= controller_name %>Controller < ApplicationController

  layout "web"

  def index
    session[:<%= feature_name %>] ||= { }
    session[:<%= feature_name %>][:tag] = nil
    session[:<%= feature_name %>][:month] = nil
    redirect_to :action => 'list'
  end

  def init_year
    @months = []
    @year = params[:year].to_i || Date.today.year
    last = 12
    last = Date.today.month unless @year != Date.today.year
    for month in (0 ... last)
      @months << [month, <%= class_name %>.count(:conditions => ["month(date) = #{month+1} and year(date) = #{@year}"])]
    end
    @months.reverse!
  end

  def ajax_year
    init_year
    render(:layout => false)
  end


  def init_navigation
    session[:<%= feature_name %>] ||= { }
    @tags = <%= class_name %>.all_tags_array.sort
    init_year
    @years = []
    earliest = <%= class_name %>.find(:first, :order => "date asc")
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
    session[:<%= feature_name %>][:tag] = params[:tag] if params[:tag]
    if params[:month]
      session[:<%= feature_name %>][:month] = params[:month]
      session[:<%= feature_name %>][:tag] = nil
    end
    if session[:<%= feature_name %>][:tag]
      @<%= plural_name %> = <%= class_name %>.find_tagged(session[:<%= feature_name %>][:tag]).all(:order => 'date desc')
      @list_name = session[:<%= feature_name %>][:tag]
    else
      if session[:<%= feature_name %>][:month]
        params[:year] ||= Date.today.year
        @<%= plural_name %> = <%= class_name %>.all_from_date(session[:<%= feature_name %>][:month].to_i + 1, params[:year])
      else
        @<%= plural_name %> = <%= class_name %>.find_recent(10)
        @list_name = "Latest Headlines"
      end
    end
    @<%= plural_name %>, @<%= singular_name%>_pages = Pager.pages(@<%= plural_name %>, params[:page] || 1, 10)
  end

  def show
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    unless @<%= singular_name %>.display?
      redirect_to :action => 'list'
    end
    params[:year] = @<%= singular_name %>.date && @<%= singular_name %>.date.year
    init_navigation
  end

end
