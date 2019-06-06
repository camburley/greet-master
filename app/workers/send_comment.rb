class SendComment
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(text, comment_id, page_token)
    data = {
      message: text
    }

    url = URI.parse("https://graph.facebook.com/v2.10/#{comment_id}/comments?access_token=#{page_token}")

    http = Net::HTTP.new(url.host, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE #only for development.
    begin
      request = Net::HTTP::Post.new(url.request_uri)
      request["Content-Type"] = "application/json"
      request.body = data.to_json
      response = http.request(request)
      body = JSON(response.body)
      return { ret: body["error"].nil?, body: body }
    rescue => e
      raise e
    end
  end
end
