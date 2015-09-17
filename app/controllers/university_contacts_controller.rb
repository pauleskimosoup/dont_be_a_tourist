class UniversityContactsController < ApplicationController

  layout "web"

  def new
    @university_contact = UniversityContact.new
    get_universities
  end

  def create
    @university_contact = UniversityContact.new(params[:university_contact])

    if @university_contact.valid?

      @university_contact.send_to_insightly
      UniversityContactMailer.deliver_new_contact(@university_contact)
      # send email
      flash[:notice] = "Thank you for submitting your details"
      redirect_to :controller => "web", :action => "download_mini_guides"
    else
      get_universities
      render :action => 'new'
    end
  end

  private

  def get_universities
    require "net/http"
    require "net/https"
    require "uri"
    api_key = "980534cc-2cc7-4045-98a4-383f9f1d1733"
    uri = URI.parse('https://api.insight.ly/v2/Organisations?tag=University')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(api_key, nil)
    response = http.request(request)
    @universities = JSON.parse(response.body).map{|x| [x["ORGANISATION_NAME"], x["ORGANISATION_ID"]]}
  end
end
