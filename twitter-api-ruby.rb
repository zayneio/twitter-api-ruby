require 'httparty'
require 'byebug'
class TwitterApi
  attr_accessor :consumer_key, :consumer_secret, :bearer

  # Set our keys and bearer if we have it when we initialize the class
  def initialize(consumer_key, consumer_secret, bearer=nil)
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret
    @bearer = bearer || auth
  end

  # This method authorizes our Twitter API use and returns a bearer token if we do not already have one
  # https://developer.twitter.com/en/docs/basics/authentication/overview/application-only  
  def auth
    credentials = Base64.encode64("#{@consumer_key}:#{@consumer_secret}").gsub("\n", '')
    url = "https://api.twitter.com/oauth2/token"
    body = "grant_type=client_credentials"
    headers = {
      "Authorization" => "Basic #{credentials}",
      "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"
    }
    r = HTTParty.post(url, body: body, headers: headers)
    bearer_token = JSON.parse(r.body)['access_token']
  end

  # == Action ==
  # Makes a search request to Twitter API based on a specific keyword, returns a list of tweet objects
  # == Inputs ==
  # keyword: string
  # max_id: integer, the id of the last tweet in each bulk collection request
  # count: integer
  # limit: integer
  # result_type: string #options: 'mixed', 'recent', 'popular'
  # == Response == 
  # Returns an array of tweets on a given keyword, optionally filtered
  def search(keyword, count=100, limit=200, result_type='mixed', max_id=nil)	
	tweets = Array.new
	while tweets.count < limit
	  url = "https://api.twitter.com/1.1/search/tweets.json?q=#{keyword}&result_type=#{result_type}&count=#{count}"
	  url += "&max_id=#{max_id}" if !max_id.nil?
	  response = build_request(url)
	  tweets += response['statuses']
	  max_id = tweets.last['id']
	  puts "collecting tweets, current count #{tweets.count}"
	end
	tweets
  end

  # Get user by their twitter handle
  def get_user_by_screen_name(screen_name)
    url = "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{screen_name}"
    response = build_request(url)
  end

  # Get user by ID
  # https://developer.twitter.com/en/docs/accounts-and-users/follow-search-get-users/api-reference/get-users-lookup	
  def get_user_by_id(id)
  	api_auth_header = {"Authorization" => "Bearer #{@bearer}"}
	url = 'https://api.twitter.com/1.1/users/lookup.json?user_id=' + user_id.to_s
	response = build_request(url)
  end

  def build_request(url)
	api_auth_header = {"Authorization" => "Bearer #{@bearer}"}
	response = JSON.parse(HTTParty.get(url, headers: api_auth_header).body)
  end

end

# # EXAMPLES # #
# # # # # # # # # # # # # # # # # # # # # # # # # 
# tw = TwitterApi.new(consumer_key, consumer_secret)
# OR
# tw = TwitterApi.new(consumer_key, consumer_secret, bearer)
