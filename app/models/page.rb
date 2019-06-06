class Page < ApplicationRecord
	belongs_to :user
  has_many :posts
  has_many :campaigns
	has_many :short_links

	resourcify

  def self.create_pages(user_id, data)
    if data && user_id
      user = User.find_by_uid(user_id)
      data.each do |k, v|
        where(page_id: v["id"]).first_or_initialize.tap do |page|
          page.user_id = user.id
          page.echo = true
          page.name = v["name"]
          page.category =  v["category"]
          page.page_id = v["id"]
          page.picture = v["picture"]["data"]["url"]
          page.oauth_token = v["access_token"]
          page.webhook = create_sub(v["id"], v["access_token"])
          page.instagram_id = v["instagram_business_account"]["id"] if v["instagram_business_account"]
          page.save!
        end
      end
    end
  end

  def self.create_sub(page_id, token)
		uri = URI.parse("https://graph.facebook.com/v3.0/#{page_id}/subscribed_apps?access_token=#{token}")
		request = Net::HTTP::Post.new(uri)
		req_options = { use_ssl: uri.scheme == "https" }
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
    response.body["success"] ? true : false
	end

	def self.remove_sub(page_id, token)
		uri = URI.parse("https://graph.facebook.com/v3.0/#{page_id}/subscribed_apps?access_token=#{token}")
		request = Net::HTTP::Delete.new(uri)
		req_options = { use_ssl: uri.scheme == "https" }
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
	end
end