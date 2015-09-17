class DocumentController < ApplicationController
  layout false

  def dialog
    @documents = Document.all(:order => :filename)
  end

  def upload
    unless request.post?
      @document = Document.new
    else
      @document = Document.create(params[:document])
      redirect_to :action => :dialog
    end
  end
end
