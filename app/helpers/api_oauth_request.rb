require 'json'
require 'oauth'

class ApiOauthRequest

	HEADERS = {"Content-Type": "application/x-www-form-urlencoded"}

	attr_accessor :keys,
	              :twitter_api,
	              :base_url,
	              :uri_path

	def initialize(*params)
		@base_url = 'https://api.twitter.com/'
		@uri_path = '/1.1/account_activity/all/env-beta'

    params = params.first if params.first

    @keys = {}
    @keys['consumer_key'] = params && params["consumer_key"] ? params["consumer_key"] : ENV['TW_CONSUMER_KEY']
    @keys['consumer_secret'] = params && params["consumer_secret"] ? params["consumer_secret"] : ENV['TW_CONSUMER_SECRET']
    @keys['access_token'] = params && params["access_token"] ? params["access_token"] : ENV['TW_ACCESS_TOKEN']
    @keys['access_token_secret'] = params && params["access_token_secret"] ? params["access_token_secret"] : ENV['TW_ACCESS_SECRET']

    puts "==============="
    puts @keys
    puts "==============="
	end


# ==============
# AUTHENTICATION
# ==============
	def get_api_access()
		consumer = OAuth::Consumer.new(@keys['consumer_key'], @keys['consumer_secret'], {:site => @base_url})
		token = {:oauth_token => @keys['access_token'],
		         :oauth_token_secret => @keys['access_token_secret']
		}

		@twitter_api = OAuth::AccessToken.from_hash(consumer, token)
	end


# ========
# REQUESTS
# ========
	def make_post_request(uri_path)
		get_api_access if @twitter_api.nil?
		response = @twitter_api.post(uri_path, HEADERS)

		if response.code.to_i >= 300
			puts "POST ERROR occurred with #{uri_path}"
			puts "Error code: #{response.code} #{response}"
			puts "Error Message: #{response.body}"
    end

    return response.body
	end

	def make_get_request(uri_path)
		get_api_access if @twitter_api.nil?

		response = @twitter_api.get(uri_path, HEADERS)

		if response.code.to_i >= 300
			puts "GET ERROR occurred with #{uri_path}: "
			puts "Error: #{response}"
    end

    return response.body
	end

	def make_delete_request(uri_path)
		get_api_access if @twitter_api.nil?

		response = @twitter_api.delete(uri_path, HEADERS)

		if response.code.to_i >= 300
			puts "DELETE ERROR occurred with #{uri_path}: "
			puts "Error: #{response}"
    end

    return response.body
	end

	def make_put_request(uri_path)
		get_api_access if @twitter_api.nil?

		response = @twitter_api.put(uri_path, '', {"content-type" => "application/json"})

		if response.code.to_i == 429
			puts "#{response.message}  - Rate limited..."
		end

		if response.code.to_i >= 300
			puts "PUT ERROR occurred with #{uri_path}, request: #{request} "
			puts "Error: #{response}"
    end

    return response.body
	end
end
