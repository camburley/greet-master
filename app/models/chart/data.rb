class Chart::Data

  def initialize(post_ids, period, platform="all")
    @post_ids = post_ids ||= nil
    @start_date = (period[0] ? period[0] : nil).to_datetime
    @end_date = (period[1] ? period[1] : Date.today.end_of_day).to_datetime
    @platform = platform

    if @post_ids && @start_date && @end_date
      if @platform == "all"
        @comments = Comment.where(post_id: @post_ids, created_at: @start_date..@end_date)
      else
        @comments = Comment.where(post_id: @post_ids, platform: @platform, created_at: @start_date..@end_date)
      end
    end
  end

  # TOTAL COMMENTS COUNT
  def get_total_comment_count
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  # GET REACTIONS
  def get_reactions
    if @post_ids
      values = {user: [], client: []}
      @start_date.upto(@end_date) do |day|
        user_sum = 0

        user_value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(:team_responded => true).map{|c| c.echo_reactions.each{|k, v| user_sum += v.to_i }}
        client_value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(team_reacted: true).size

        values[:user] << {"day": day, "value": user_sum}
        values[:client] << {"day": day, "value": user_sum}
      end
      return values
    end
  end

  def get_comments
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where.not(:wit_flag => [nil, "no_match"]).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_auto_responses
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(echo_responded: true).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_open_responses
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where.not(:wit_flag => [nil, "no_match"], :team_responded => true, :echo_responded => true).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_mentions
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(mention: true).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_jumbo_message
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(wit_flag: "jumbo_message").count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_spam
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(wit_flag: "domain_block").count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_team_responses
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where(team_responded: true).where.not(wit_flag: [nil, "no_match"]).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_tags
    if @post_ids
      values = []
      @start_date.upto(@end_date) do |day|
        value = @comments.where(created_at: day.beginning_of_day..day.end_of_day).where.not(tags: nil).count
        values << {"day": day, "value": value}
      end
      return values
    end
  end

  def get_brand_feedback
    if @post_ids
      love_values = []
      hate_values = []
      @start_date.upto(@end_date) do |day|
        comments = @comments.where(created_at: day.beginning_of_day..day.end_of_day)

        love = comments.where(:user_feedback => "love").count
        hate = comments.where(created_at: day.beginning_of_day..day.end_of_day).where(:user_feedback => "disappointment").count
        love_values << {"day": day, "value": love}
        hate_values << {"day": day, "value": hate}
      end

      return {"love" => love_values, "hate" => hate_values}
    end
  end
end
