class Comment < ApplicationRecord
  belongs_to :post

  def self.create_comment(post_id, comment_id, message, sender_id, sender_name)
    where(comment_id: comment_id).first_or_initialize do |comment|
      comment.post_id = post_id
      comment.comment_id = comment_id
      comment.message = message
      comment.sender_id = sender_id
      comment.sender_name = sender_name
      comment.save!
    end
  end

  def self.get_new_comments(post_id, token)
    post = Post.find_by_id(post_id)

    if post
      uri = URI.parse("https://graph.facebook.com/v3.0/#{post.post_id}/comments?fields=id,from,message,message_tags,created_time&limit=100&access_token=#{token}")
      response = Net::HTTP.get_response(uri)

      comments = JSON.parse(response.body)
      if comments && comments["data"]
        comments["data"].each do |c|
          comment = create_comment(post_id, c["id"], c["message"])
          comment.created_at = c["created_time"]
          tags = c["message_tags"] ? c["message_tags"] : nil

          if tags
            page = Page.find_by_id(post.page_id)
            comment.tags = tags
            comment.mention = true if tags[0]["name"] == page.name
          end

          if comment.persisted?
            unless comment.wit_object && comment.perspective
              wit_json = Webhook::Dependencies.new.wit_data(comment.message)

              if wit_json
                comment.wit_object = wit_json
                wit_response = "Wit::Bombas".constantize.get_response(wit_json)

                if wit_response
                  if wit_response[:intent]
                    comment.intent = wit_response[:intent]
                  elsif wit_response[:user_feedback]
                    comment.user_feedback = wit_response[:user_feedback]
                  elsif wit_response[:wit_flag]
                    comment.wit_flag = wit_response[:wit_flag]
                  end
                end
              end

              # GET PERSPECRIVE API
              perspective = Webhook::Dependencies.new.perspective(comment.message)
              if perspective
                comment.perspective = perspective
              end
            end

            comment.save!
          end
        end
      end
    end
  end

  # GET DB DATA
  class Data
    def initialize(post_ids, period, platform="all")
      @post_ids = post_ids ||= nil
      @start_date = period[0] ? period[0] : nil
      @end_date = period[1] ? period[1] : Date.today.end_of_day
      @platform = platform

      if @post_ids && @start_date && @end_date
        if @platform == "all"
          @comments = Comment.where(post_id: @post_ids, created_at: @start_date..@end_date)
        else
          @comments = Comment.where(post_id: @post_ids, platform: @platform, created_at: @start_date..@end_date)
        end
      end
    end

    # GET COMMENT MSSAGES
    def self.get_comment_message(id)
      if id
        comment = Comment.find_by(:comment_id => id).as_json(only: [:message, :echo_message])
        return comment
      end
    end

    # GET COMMENTS
    def self.get_comments(id)
      if id
        post = Post.find_by(:post_id => id)
        comments = post.comments.order('created_at DESC').as_json(only: [:comment_id, :sender_name, :created_at, :echo_responded, :team_responded, :wit_flag, :mention])
        return {"comments": comments}
      end
    end


# DATA
    # TOTAL COMMENTS COUNT
    def get_total_comment_count
      total = @comments.size
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Total Conversations", "desc": "All comments" }
    end

    # RETURNING COUNT
    def get_total_questions
      total = @comments.where('intent IS NOT NULL OR wit_flag = ?', "user_question").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Total Customer Questions", "desc": "Customer Questions" }
    end

    # RESPONDED BY ECHO
    def get_auto_responses
      total = @comments.where(echo_responded: true).where('intent IS NOT NULL OR wit_flag = ?', "user_question").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return {"total" => total, "per_post" => total_per_post}
    end

    # RESPONDED BY CLIENT
    def get_team_responses
      total = @comments.where(team_responded: true).where('intent IS NOT NULL OR wit_flag = ?', "user_question").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Customer Questions Answered", "desc": "Team Responses" }
    end

    # RESPONDED BY CLIENT
    def get_open_questions
      total = @comments.where(team_responded: [nil, false]).where('intent IS NOT NULL OR wit_flag = ?', "user_question").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Open Customer Questions", "desc": "Customer Care Needed" }
    end

    # GET MENTIONS
    def get_mentions
      total = @comments.where(mention: true).count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Total Mentions", "desc": "Public Callouts" }
    end

    # COMMENT WITH TAGS
    def get_tags
      total = @comments.where.not(tags: nil, mention: true).count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Friend Tags", "desc": "Friend Tags" }
    end

    # LONGER MESSAGE THAN 140 CHARS
    def get_jumbo_message
      total = @comments.where(wit_flag: "jumbo_message").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Long Messages", "desc": "240 Characters+ Messages" }
    end

    # BRAND COMMENT LOVE/HATE
    def get_brand_feedback
      love = @comments.where(:user_feedback => "love").count
      disappointment = @comments.where(:user_feedback => "disappointment").count
      love_per_post = love ? (love / @post_ids.size.to_f).round(1) : 0
      disappointment_per_post = disappointment ? (disappointment / @post_ids.size.to_f).round(1) : 0

      love_data = { "total": love, "per_post": love_per_post, "title": "Positive Sentiment", "desc": "Public Embrace" }
      disappointment_data = { "total": disappointment, "per_post": disappointment_per_post, "title": "Negative Sentiment", "desc": "Product/Service Disappointment" }

      return {"love": love_data, "disappointment": disappointment_data}
    end

    # GET SPAM
    def get_spam
      total = @comments.where(wit_flag:  "domain_block").count
      total_per_post = total ? (total / @post_ids.size.to_f).round(1) : 0
      return { "total": total, "per_post": total_per_post, "title": "Spam", "desc": "3rd Party Links" }
    end

    # GET REACTIONS
    def get_reactions
      user_sum = 0

      user = @comments.where(:team_responded => true).map{|c| c.echo_reactions.each{|k, v| user_sum += v.to_i }}
      user_per_post = user_sum ? (user_sum / @post_ids.size.to_f).round(1) : 0

      client = @comments.where(team_reacted: true).size
      client_per_post = client ? (client / @post_ids.size.to_f).round(1) : 0

      user_data = { "total": user_sum, "per_post": user_per_post, "title": "User's Reactions", "desc": "Reactions to Brand Comments" }
      client_data = { "total": client, "per_post": client_per_post, "title": "Brand's Reactions", "desc": "Brand Reacted to Comments" }

      return {"user": user_data, "client": client_data}
    end

    # GET DATA INTENTS
    def get_wit_intents(key)
      comments = @comments

      intents_comments = comments.where.not(intent: nil)
      questions_comments = comments.where(intent: nil, wit_flag: "user_question")

      if key == "total_comments"
        intents = comments
        result = {total_comments: intents.size}
      elsif key == "user_reactions"
        ids = []
        intents = comments.where(:team_responded => true).map{|c| c.echo_reactions.each{|k, v| ids << c.id if v.to_i > 0 }}
        result = {user_reactions: ids.uniq.size}
      elsif key == "brand_reactions"
        intents = comments.where(:team_reacted => true)
        result = {"brand_reactions": intents.size}
      elsif key == "total_questions"
        intents = intents_comments
        questions = questions_comments
      elsif key == "team_questions"
        intents = intents_comments.where(team_responded: true)
        questions = questions_comments.where(team_responded: true)
      elsif key == "open_questions"
        intents = intents_comments.where(team_responded: [nil, false])
        questions = questions_comments.where(team_responded: [nil, false])
      elsif key == "mentions"
        intents = comments.where(mention: true)
        result = {mentions: intents.size}
      elsif key == "tags"
        intents = comments.where.not(tags: nil, mention: true)
        result = {tags: intents.size}
      elsif key == "long_message"
        intents = comments.where(wit_flag: "jumbo_message")
        result = {jumbo_message: intents.size}
      elsif key == "love"
        intents = comments.where(user_feedback: "love")
        result = {love: intents.size}
      elsif key == "disappointment"
        intents = comments.where(user_feedback: "disappointment")
        result = {disappointment: intents.size}
      elsif key == "domain_block"
        intents = comments.where(wit_flag: "domain_block")
        result = {domain_block: intents.size}
      end

      if questions
        data = (intents.group(:intent).having("count(*) > 0").size).merge(questions.group(:wit_flag).having("count(*) > 0").size)
      else
        data = result
      end


      return data if data
    end

    # GET DATA INTENTS
    def get_wit_messages(key, intent)
      comments = @comments

      if key == "total_comments"
        list = comments
      elsif key == "user_reactions"
        ids = []
        comments.where(:team_responded => true).map{|c| c.echo_reactions.each{|k, v| ids << c.id if v.to_i > 0 }}
        list = comments.where(id: ids)
      elsif key == "brand_reactions"
        list = comments.where(:team_reacted => true)
      elsif key == "total_questions"
        if intent == "user_question"
          list = comments.where(wit_flag: intent, intent: nil)
        else
          list = comments.where(intent: intent)
        end
      elsif key == "team_questions"
        if intent == "user_question"
          list = comments.where(team_responded: true, wit_flag: intent, intent: nil)
        else
          list = comments.where(team_responded: true, intent: intent)
        end
      elsif key == "open_questions"
        if intent == "user_question"
          list = comments.where(team_responded: [nil, false], wit_flag: intent, intent: nil)
        else
          list = comments.where(team_responded: [nil, false], intent: intent)
        end
      else
        if intent == "mentions"
          list = comments.where(:mention => true)
        elsif intent == "tags"
          list = comments.where.not(:tags => nil, :mention => true)
        elsif ["jumbo_message", "domain_block", "user_question"].include?(intent)
          list = comments.where(wit_flag:  intent)
        elsif intent == "love"
          list = comments.where(:user_feedback => "love")
        elsif intent == "disappointment"
          list = comments.where('user_feedback = ?', "disappointment")
        else
          list = comments.where(intent: intent)
        end
      end

      if list
        messages = list.order('created_at DESC').select(:id, :comment_id, :message, :team_responded, :echo_message, :platform, :link, :created_at)
        return messages
      end
    end

    #GET TAGS
    def get_tags_insight(tags)
      data = []
      tags.each do |tag|
        conv_data = @comments.where("lower(message) LIKE lower(?)", "%#{tag}%")
        conversations = conv_data.size
        positive = ((conv_data.where(user_feedback: "love").size.to_f / @comments.size.to_f) * 100).round(1) rescue 0

        data << {"tag": tag, "conversations": conversations, "pos_conversation": positive}
      end

      return data if data
    end

    #GET TAGS
    def get_tag_messages(tag)
      tags = @comments.where("lower(message) LIKE lower(?)", "%#{tag}%").as_json(only: [:comment_id, :sender_name, :created_at, :message])
      return tags if tags
    end
  end
end
