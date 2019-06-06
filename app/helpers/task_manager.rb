require 'json'

require_relative '../helpers/api_oauth_request'

class TaskManager

	attr_accessor :twitter_api,
	              :webhook_configs

	def initialize(*params)
    puts "==============="
    puts params.first
    puts "==============="

		@twitter_api = ApiOauthRequest.new(params.first)
		@twitter_api.uri_path = '/1.1/account_activity/all/env-beta'
		@twitter_api.get_api_access()

		@webhook_configs = []
	end

	def get_webhook_configs
		puts "Retrieving webhook configurations..."

		uri_path =  "#{@twitter_api.uri_path}/webhooks.json"
		response = @twitter_api.make_get_request(uri_path)
		results = JSON.parse(response)

		if results.count == 0
			puts "No existing configurations... "
		else
			results.each do |result|
				@webhook_configs << result
			end
		end

		@webhook_configs
	end

	def set_webhook_config(url)
		puts "Setting a webhook configuration..."

		uri_path = "#{@twitter_api.uri_path}/webhooks.json?url=#{url}"
		response = @twitter_api.make_post_request(uri_path, nil)
    results = JSON.parse(response)

		if results['errors'].nil?
			puts "Created webhook instance with webhook_id: #{results['id']} | pointing to #{results['url']}"
		end

		results
	end

	def delete_webhook_config(id)
		puts "Attempting to delete configuration for webhook id: #{id}."

		uri_path =  "#{@twitter_api.uri_path}/webhooks/#{id}.json"
		response = @twitter_api.make_delete_request(uri_path)

		if response == '204'
			puts "Webhook configuration for #{id} was successfully deleted."
		end

		response
	end

	def get_webhook_subscription(id)
		puts "Retrieving webhook subscriptions..."

		uri_path = "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"
		response = @twitter_api.make_get_request(uri_path)

		if response == '204'
			puts "Webhook subscription exists for #{id}."
		end

		response
	end

	# Sets a subscription for
	# https://dev.twitter.com/webhooks/reference/post/account_activity/webhooks/subscriptions
	def set_webhook_subscription(id)
		puts "Setting subscription for 'host' account for webhook id: #{id}"

		uri_path = "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"
		response = @twitter_api.make_post_request(uri_path, nil)

		if response == '204'
			puts "Webhook subscription for #{id} was successfully added."
		end

    response
	end

	def delete_webhook_subscription(id)
		puts "Attempting to delete subscription for webhook: #{id}."
		uri_path =  "#{@twitter_api.uri_path}/webhooks/#{id}/subscriptions.json"
		response = @twitter_api.make_delete_request(uri_path)

		if response == '204'
			puts "Webhook subscription for #{id} was successfully deleted."
		end

		response
	end

	# https://dev.twitter.com/webhooks/reference/put/account_activity/webhooks
	# PUT https://api.twitter.com/1.1/account_activity/webhooks/:webhook_id.json
	def confirm_crc(id)

		uri_path =  "#{@twitter_api.uri_path}/webhooks/#{id}.json"
		response = @twitter_api.make_put_request(uri_path)

		if response == '204'
			puts "CRC request successful and webhook status set to valid."
		end

		response
	end

end
