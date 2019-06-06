Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], size: 3}
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], size: 8 }
end
