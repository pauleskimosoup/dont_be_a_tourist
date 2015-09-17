class <%= controller_name %>Controller < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @<%= plural_name %>, @<%= file_name %>_pages = <%= class_name %>.paginate_and_order(params.merge({:conditions => "display=1"}))
  end

  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    unless @<%= file_name %>.display?
      redirect_to :action => 'list'
    end
  end

end
