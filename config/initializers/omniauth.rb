OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "#{ENV['FB_APP_ID']}", "#{ENV['FB_APP_SECRET']}",
  client_options: {
      site: 'https://graph.facebook.com/v3.0',
      authorize_url: "https://www.facebook.com/v3.0/dialog/oauth"
  },
  :info_fields => 'first_name, last_name, accounts',
  :scope => 'public_profile,manage_pages,publish_pages,read_insights,instagram_basic',
  :auth_type => 'reauthenticate'
end
