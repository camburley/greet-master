Rails.application.routes.draw do
  constraints subdomain: "api" do
    root 'home#api_documentation'
  end

  root 'home#index'

  # Auth User
  post '/sign_in' => 'sessions#create'
  get '/sign_out' => 'sessions#destroy'
  match '/create_company' => 'home#company', via: [:get, :post]

  # Admin
  scope 'admin' do
  	get '/' => 'admin#stats', as: 'admin'
    match '/posts' => 'admin#posts', as: 'admin_posts', via: [:get, :put, :post]
    match '/campaign' => 'admin#campaign', as: 'admin_campaign', via: [:get, :put, :post]

    scope 'settings' do
      match '/' => 'admin#settings', as: 'admin_settings', via: [:get, :put]
      get '/pages' => 'admin#settings_pages', as: 'admin_settings_pages'
      get '/team' => 'admin#settings_team', as: 'admin_settings_team'
    end
  end

  scope 'api' do
    scope 'v1' do
      get '/page/:page_id' => 'api#insights'
      get '/post/:page_id' => 'api#post_insights'
      get '/posts/:page_id' => 'api#posts'
      get '/intents/:page_id/:key' => 'api#wit_data_intents'
      get '/tags/:page_id' => 'api#tags_insights'
      get '/messages/:page_id/:key/:intent' => 'api#wit_data_messages'
      get '/graph/:page_id' => 'api#chart_data'
      get '/campaigns/:page_id' => 'api#campaigns'
      get '/campaign_data/:page_id' => 'api#campaign_data'
      get '/campaign_compare_data/:page_id' => 'api#campaign_compare_data'
      get '/campaign_posts/:page_id' => 'api#campaign_post_data'
      get '/tag_insights/:page_id' => 'api#tag_insights'
      get '/short_links/:link_id' => 'api#short_link_clicks'
      # post '/send_message/:comment_id' => 'api#send_message'

      # Authenticate
      post '/authenticate', to: 'api#authenticate'
    end
  end

  namespace :webhook do
    post '/facebook', to: 'facebook#callback'
    get '/facebook', to: 'facebook#verify_callback'
  end
end
