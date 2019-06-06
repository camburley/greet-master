class ApiController < ActionController::API
  before_action :authenticate_request, :set_data

  def insights(extras=nil)
		if @post_ids
      total_comments =  Comment::Data.new(@post_ids, @period, @platform).get_total_comment_count
      reactions = Comment::Data.new(@post_ids, @period, @platform).get_reactions
			total_questions = Comment::Data.new(@post_ids, @period, @platform).get_total_questions
			team_questions = Comment::Data.new(@post_ids, @period, @platform).get_team_responses
			open_questions = Comment::Data.new(@post_ids, @period, @platform).get_open_questions
			mentions = Comment::Data.new(@post_ids, @period, @platform).get_mentions
			tags = Comment::Data.new(@post_ids, @period, @platform).get_tags
			long_message = Comment::Data.new(@post_ids, @period, @platform).get_jumbo_message
      feedback = Comment::Data.new(@post_ids, @period, @platform).get_brand_feedback
			spam = Comment::Data.new(@post_ids, @period, @platform).get_spam

      # data = {
      #           total_comments: total_comments,
      #           love: feedback[:love],
      #           disappointment: feedback[:disappointment]
      #        }

			data = {
                total_comments: total_comments,
                user_reactions: reactions[:user],
                brand_reactions: reactions[:client],
                total_questions: total_questions,
                team_questions: team_questions,
                open_questions: open_questions,
                mentions: mentions,
                tags: tags,
                long_message: long_message,
                love: feedback[:love],
                disappointment: feedback[:disappointment],
                domain_block: spam
             }
    
    end

    if extras
      data.merge!({"extras": extras})
    end

    #SEND DATA
    send_response(data)
  end

  # POST INSIGHT
  def post_insights
    if @post_ids && @period
      data = []

      @post_ids.each do |id|
        total_comments =  Comment::Data.new(@post_ids, @period, @platform).get_total_comment_count
        total_questions = Comment::Data.new(id, @period).get_total_questions
        team_questions = Comment::Data.new(id, @period).get_team_responses
        open_questions = Comment::Data.new(id, @period).get_open_questions
        mentions = Comment::Data.new(id, @period).get_mentions
        tags = Comment::Data.new(id, @period).get_tags
        feedback = Comment::Data.new(id, @period).get_brand_feedback
        long_message = Comment::Data.new(id, @period).get_jumbo_message
        spam = Comment::Data.new(id, @period).get_spam

        # post_data = {
        #           total_comments: total_comments,
        #           love: feedback[:love],
        #           disappointment: feedback[:disappointment]
        #        }

        post_data = {
                  total_comments: total_comments,
                  total_questions: total_questions,
                  team_questions: team_questions,
                  open_questions: open_questions,
                  mentions: mentions,
                  tags: tags,
                  long_message: long_message,
                  love: feedback[:love],
                  disappointment: feedback[:disappointment],
                  domain_block: spam
               }
        data << post_data
      end
    end

    #SEND DATA
    send_response(data)
  end

  # GET POSTS
  def posts
    if request.xhr? && Page.find_by(page_id: params[:page_id])
      page = Page.find_by(page_id: params[:page_id])
      data = page.posts

      send_response(data)
    end
  end

  # GET CAMPAIGNS && DATA
  def campaigns
    if request.xhr? && Page.find_by(page_id: params[:page_id])
      page = Page.find_by(page_id: params[:page_id])
      data = page.campaigns

      send_response(data)
    end
  end

  def campaign_data
    if @campaign_id && Campaign.find_by(id: @campaign_id)
      campaign = Campaign.find_by(id: @campaign_id)
      page = campaign.page

      @period = [campaign.start_date, campaign.end_date]
      @post_ids = page.posts.where(created_at: campaign.start_date..campaign.end_date).ids
      insights(page.as_json(only: [:page_id, :name, :picture]))
    end
  end

  def campaign_compare_data
    if @campaign_id && Campaign.find_by(id: @campaign_id)
      campaign = Campaign.find_by(id: @campaign_id)
      page = campaign.page

      compare_posts = []
      compare_pages = Page.where(id: campaign.compare)
      compare_pages.each do |c|
        compare_posts << c.posts.where(created_at: campaign.start_date..campaign.end_date).ids
      end

      if compare_posts.any?
        @period = [campaign.start_date, campaign.end_date]
        @post_ids = compare_posts.flatten
        insights(compare_pages.as_json(only: [:page_id, :name, :picture]))
      end
    end
  end

  def campaign_post_data
    if @campaign_id && Campaign.find_by(id: @campaign_id)
      campaign = Campaign.find_by(id: @campaign_id)
      pages = Page.where(id: [campaign.page_id, campaign.compare].flatten)

      data = []

      pages.each do |page|
        posts = page.posts.where(created_at: campaign.start_date..campaign.end_date)
        data << {page: page.as_json(only: [:page_id, :name, :picture]), compare_post: campaign.compare_post, posts: posts.as_json(only: [:id, :message, :image, :link, :fb_created])}
      end

      send_response(data)
    end
  end

  # TAGS INSIGHS
  def tag_insights
    if @campaign_id && Campaign.find_by(id: @campaign_id)
      campaign = Campaign.find_by(id: @campaign_id)
      page = campaign.page
      page_posts = page.posts.where(created_at: campaign.start_date..campaign.end_date).ids
      @period = [campaign.start_date, campaign.end_date]

      compare_posts = []
      compare_pages = Page.where(id: campaign.compare)
      compare_pages.each do |c|
        compare_posts << c.posts.where(created_at: campaign.start_date..campaign.end_date).ids
      end

      if @page && @period && compare_pages
        page_data = Comment::Data.new(page_posts, @period).get_tags_insight(campaign.tags)
        compare_data = Comment::Data.new(compare_posts.flatten, @period).get_tags_insight(campaign.tags)
        data = {"page": page_data, "compare": compare_data}

        send_response(data)
      end
    end
  end

  # CHART DATA
	def chart_data
		if @post_ids
      total_comments =  Chart::Data.new(@post_ids, @period, @platform).get_total_comment_count
      reactions = Chart::Data.new(@post_ids, @period, @platform).get_reactions
			total_questions = Chart::Data.new(@post_ids, @period, @platform).get_comments
			open_questions = Chart::Data.new(@post_ids, @period, @platform).get_open_responses
			team_questions = Chart::Data.new(@post_ids, @period, @platform).get_team_responses
			tags = Chart::Data.new(@post_ids, @period, @platform).get_tags
			mentions = Chart::Data.new(@post_ids, @period, @platform).get_mentions
			long_message = Chart::Data.new(@post_ids, @period, @platform).get_jumbo_message
			spam = Chart::Data.new(@post_ids, @period, @platform).get_spam
			feedback = Chart::Data.new(@post_ids, @period, @platform).get_brand_feedback

      # data = {
      #          total_comments: total_comments,
      #          love: feedback["love"],
      #          disappointment: feedback["hate"]
      #        }

			data = {
               total_comments: total_comments,
               user_reactions: reactions[:user],
               brand_reactions: reactions[:client],
               total_questions: total_questions,
               team_questions: team_questions,
               open_questions: open_questions,
               mentions: mentions,
               tags: tags,
               long_message: long_message,
               love: feedback["love"],
               disappointment: feedback["hate"],
               domain_block: spam
             }
		end

    #SEND DATA
    send_response(data)
	end

  #BEGIN GET WIT INTENTS
  def wit_data_intents
    if @post_ids
      if @key
        data = Comment::Data.new(@post_ids, @period, @platform).get_wit_intents(@key)
      else
        render status: 400, json: {"message": "Missing parameters!"} and return false

      end
    end

    #SEND DATA
    send_response(data)
  end

  #BEGIN wit_data
	def wit_data_messages
		if @post_ids
      if @key && @intent
        data = Comment::Data.new(@post_ids, @period, @platform).get_wit_messages(@key, @intent)
      else
        render status: 400, json: {"message": "Missing parameters!"} and return false
      end
    end

    #SEND DATA
    send_response(data)
	end

  def tags_insights
    if @post_ids
      if @tag
        data = Comment::Data.new(@post_ids, @period, @platform).get_tag_messages(@tag)
      else
        render status: 400, json: {"message": "Missing parameters!"} and return false
      end
    end

    #SEND DATA
    send_response(data)
  end

  private
  
    def set_data
      @post_ids = params[:post_ids] ? params[:post_ids].split(',').map(&:to_i) : @page.posts.ids
      @campaign_id = params[:campaign_id] ? params[:campaign_id] : nil
      @period = params[:period] == "year" ? [1.year.ago.to_date.beginning_of_day] :
                params[:period] == "month" ? [1.month.ago.to_date.beginning_of_day] :
                params[:period] == "two_weeks" ? [2.weeks.ago.to_date.beginning_of_day] :
                params[:period] == "week" ? [1.week.ago.to_date.beginning_of_day] :
                params[:period] == "today" ? [Date.today.beginning_of_day] : [Date.today.beginning_of_day]
      @key = params[:key] && ['total_comments', 'user_reactions', 'brand_reactions', 'total_questions','team_questions','open_questions','mentions','tags','long_message','love','disappointment','domain_block'].include?(params[:key]) ? params[:key] : nil
      @tag = params[:tag] ||= nil
      @intent = params[:intent] ||= nil
      @platform = params[:platform] ||= "all"
    end

    def send_response(data = {})
      if data && !data.empty?
        render status: 200, json: data
      elsif data.nil? || data.empty?
        render status: 204, json: {"message": "No Content!"}
      else
        render status: 400, json: {"message": "Bad Request!"}
      end
    end

    def authenticate_request
      if request.xhr?
        @page = Page.find_by(page_id: params[:page_id])
      else
        auth = Api::Authorize.new(request.headers).call
        if auth[:error]
          render status: auth[:status], json: {message: auth[:error]}
        else
          @page = auth
        end
      end
    end
end
