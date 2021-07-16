require "net/http"
require "uri"
require "json"

module ApplicationHelper
  def spreedly_post(endpoint, params = {})
    parsed_uri = URI.parse("https://core.spreedly.com/v1#{endpoint}")
    req = Net::HTTP::Post.new(parsed_uri.request_uri)
    http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
    http.use_ssl = (parsed_uri.scheme == "https")
    req.basic_auth ENV['spreedly_api_key'], ENV['spreedly_api_secret']
    req.body = params.to_json if !params.empty?
    req['Content-Type'] = 'application/json'

    response = http.request(req)
    JSON.parse(response.body)
  end

  def spreedly_get(endpoint)
    parsed_uri = URI.parse("https://core.spreedly.com/v1#{endpoint}")
    
    http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
    http.use_ssl = (parsed_uri.scheme == "https")
    
    req = Net::HTTP::Get.new(parsed_uri)
    req.basic_auth ENV['spreedly_api_key'], ENV['spreedly_api_secret']
    req['Content-Type'] = 'application/json'

    response = http.request(req)
    JSON.parse(response.body)
  end
end
