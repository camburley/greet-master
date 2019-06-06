class Webhook::FacebookController < ApplicationController
  protect_from_forgery with: :null_session
  layout false

  def callback
    messaging_event = JSON.parse(request.body.read)

    # FACEBOOK WRAPPER
    if messaging_event && messaging_event["entry"]

      if Page.find_by(:page_id =>  messaging_event["entry"][0]["id"]) || Page.find_by(:instagram_id =>  messaging_event["entry"][0]["id"])
        messaging_event["entry"][0]["changes"].each do |msg|

          page_id = messaging_event["entry"][0]["id"]
          item = msg["value"]["item"]
          field = msg["field"]

          page = Page.find_by(page_id: page_id) || Page.find_by(instagram_id: page_id)
          
          if page.echo && item == "comment" || item == "reaction" || field == "comments"
            post_id = msg["value"]["post_id"] || msg["value"]["media"]["id"]
            comment_id = msg["value"]["comment_id"] || msg["value"]["id"]
            parent_id = msg["value"]["parent_id"]
            sender_name = msg["value"]["from"]["name"] if msg["value"]["from"]
            sender_id = msg["value"]["from"]["id"] if msg["value"]["from"]
            message = msg["value"]["message"] || msg["value"]["text"]
            jumbo_message = message.length >= 240 if message
            image = msg["value"]["link"] if msg["value"]["link"]
            type = msg["value"]["reaction_type"]
            created_time = msg["value"]["created_time"]
            platform = messaging_event["object"] == "page" ? "facebook" : messaging_event["object"]

            if page.posts.find_by(:post_id => post_id)
              post = page.posts.find_by(:post_id => post_id)

              # COMMENT HANDLE
              if message && item == "comment" || field == "comments"

                # CREATING AND REPLIES FOR COMMENTS
                if page_id != sender_id || platform == "instagram" && !Comment.find_by(:comment_id => [comment_id, parent_id])

                  # CREATE COMMENT
                  comment = Comment.create_comment(post.id, comment_id, message, sender_id, sender_name)
                  comment.link = platform == "facebook" ? "https://facebook.com/#{comment_id}" : post.link
                  comment.platform = platform

                  if page.tag_response && platform == "facebook"
                    tags = Webhook::Dependencies.new.message_tags(comment_id, page.oauth_token)

                    # TAGS INCLUDED IN MESSAGE
                    tags = tags["message_tags"] ? tags["message_tags"] : nil

                    if tags # && [1,2].sample == 1
                      comment.tags = tags
                      comment.mention = true if tags[0]["name"] == page.name

                      # default = ["❤️ 🙌 Thx for sharing with friends","❤️ 🙌 Thx for sharing \n \n https://www.askideas.com/media/49/You-Are-The-Best-Friend-I-Could-Ever-Settle-For-Funny-Best-Friend-Picture.png", "❤️ 🙌 Thx for sharing with the homies","❤️ 🙌 Thx for sharing  \n https://cdn.someecards.com/someecards/filestorage/thank-you-for-understanding-that-im-way-too-lazy-to-send-an-actual-thank-you-card-alk.png", "❤️ 🙌 Thx for sharing", "❤️ 🙌 Thx for sharing. You're the best friend I could ask for online", "❤️ 🙌 Thx for sharing. The only way I could love you more is if you were made of cheese 🧀", "❤️ 🙌 Awesome! Thx for sharing ", "❤️ 🙌 Thx for sharing. And, thx for understanding I'm too lazy to write an actual thank you card."]
                      # echo_response = page.echo_response["thanks"].present? ? page.echo_response["thanks"] : default
                      # responding = echo_response.sample
                      # responding = responding.include?('[sender_name]') ? responding.gsub('[sender_name]', sender_name[/(?:^|(?:[.!?]\s))(\w+)/]) : responding
                      #
                      # if responding.match(/\[link.*\]/)
                      #   link_tag = responding.match(/\[link.*\]/).to_s
                      #   link = page.short_links.find_by(:id => link_tag[/\d+/].to_i) unless link_tag[/\d+/].nil?
                      #   responding = link && link_tag ? responding.gsub(link_tag, ENV['URL'] + "/link/" + comment.id.to_s + "_" + link.slug.to_s ) : responding = responding.gsub(link_tag, "" )
                      # end
                    end
                  end

                    # GETTING WIT RESPONSE
                  wit_json = Webhook::Dependencies.new.wit_data(message)

                  if wit_json
                    comment.wit_object = wit_json
                    wit_response = "Wit::Bombas".constantize.get_response(wit_json)

                    if wit_response
                      comment.intent = wit_response[:intent] if wit_response[:intent]
                      comment.user_feedback = wit_response[:user_feedback] if wit_response[:user_feedback]
                      comment.wit_flag = wit_response[:wit_flag] if wit_response[:wit_flag]
                    end
                  end

                  perspective = Webhook::Dependencies.new.perspective(message)
                  comment.perspective = perspective if perspective

                    # SENDING RESPONSE TO USER IF RESPONSE
                    # if responding
                      # SendComment.perform_in(1.minute, responding, comment_id, page.oauth_token)
                      # SendComment.perform_in(rand(2..5).minutes, responding, comment_id, page.oauth_token)
                      # comment.echo_responded = true

                      # comment.tags = tags if tags
                      # comment.echo_message = responding
                    # end

                  # SAVE ALL COMMENT CHANGES
                  comment.save!

                # COMMENT RESPONDED MANUALY / AUTOMATICALLY
                elsif page_id == sender_id && Comment.find_by(:comment_id => parent_id, :team_responded => false)
                  comment = Comment.find_by(:comment_id => parent_id)
                  comment.echo_id = comment_id

                  unless comment.echo_responded
                    comment.team_responded = true
                    comment.echo_message = message
                  end

                  comment.save!
                end

              # COUNTING REACTIONS
              elsif item == "reaction" && msg["value"]["comment_id"]
                if Comment.find_by(:echo_id => comment_id)
                  comment = Comment.find_by(:echo_id => comment_id)
                  result = comment.echo_reactions[type].to_i + 1

                  comment.team_reacted = true if page_id == sender_id
                  comment.echo_reactions[type] = result.to_s
                  comment.save!
                elsif Comment.find_by(:comment_id => comment_id)
                  comment = Comment.find_by(:comment_id => comment_id)
                  result = comment.reactions[type].to_i + 1

                  comment.team_reacted = true if page_id == sender_id
                  comment.reactions[type] = result.to_s
                  comment.save!
                end
              end
            else
              # GET DARK POSTS
              if item == "comment" || item == "reaction"
                Post.get_single_post(page.id, post_id)
              elsif field == "comments"
                Post.get_instagram_post(page.id, post_id)
              end
            end

          # CREATIN NEW POST
          elsif item == "status" || item == "photo" || item == "video" || item == "share"
            caption = msg["value"]["caption"] ? msg["value"]["caption"] : nil
            description = msg["value"]["description"] ? msg["value"]["description"] : nil
            link = msg["value"]["link"] ? msg["value"]["link"] : nil
            type = msg["value"]["status_type"] ? msg["value"]["status_type"] : item
            published = msg["published"] && msg["published"] == 1 ? true : false
            from = msg["value"]["from"] if sender_id == page_id

            Post.create_post(page.id, post_id, message, caption, description, link, image, type, created_time, published, true, from, platform)
          end
        end
      end
    end

    render status: 200, json: {"message": "Success!"}
  end

  def verify_callback
      challenge = params["hub.challenge"]
      verify_token = params["hub.verify_token"]

      if verify_token == "thought_you_d_ping_me"
        render :json => challenge
      else
        redirect_to root_path
      end
  end
end
