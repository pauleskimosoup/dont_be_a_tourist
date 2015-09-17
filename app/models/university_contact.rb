class UniversityContact < ActiveRecord::Base

  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :name, :string
  column :email, :string
  column :university, :string
  column :updates, :boolean
  column :adventures, :boolean

  validates_presence_of :name, :email, :university
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'address does not seem to be valid.'

  def to_insightly_hash
    contact = {
      "FIRST_NAME" => name.split(" ").first,
      "LAST_NAME" => name.split(" ")[1..-1].join(" "),
      "DEFAULT_LINKED_ORGANISATION" => university,
      "CONTACTINFOS" => [{"TYPE" => "EMAIL", "DETAIL" => email, "LABEL" => "Work"}]
    }
    contact
  end

  def send_to_insightly
    require "net/http"
    require "net/https"
    require 'json'
    require "uri"

    api_key = "980534cc-2cc7-4045-98a4-383f9f1d1733"
    uri = URI.parse('https://api.insight.ly/v2/Contacts')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.basic_auth(api_key, nil)
    request.body = self.to_insightly_hash.to_json
    response = http.request(request)
  end

  def university_name
    require "net/http"
    require "net/https"
    require "uri"
    api_key = "980534cc-2cc7-4045-98a4-383f9f1d1733"
    uri = URI.parse('https://api.insight.ly/v2/Organisations/6849524')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(api_key, nil)
    response = http.request(request)
    university = JSON.parse(response.body)
    university["ORGANISATION_NAME"]
  end

end