class Post < ApplicationRecord
  has_many :comments
  belongs_to :page

  def self.create_post(page_id, post_id, message, caption, description, link, image, type, fb_created, published, echo, from, platform)
    where(post_id: post_id).first_or_initialize.tap do |post|
      post.page_id = page_id
      post.post_id = post_id
      post.image = image
      post.message = message
      post.caption = caption
      post.description = description
      post.link = link
      post.post_type = type
      post.fb_created = fb_created
      post.published = published
      post.echo = echo
      post.from_user = from
      post.platform = platform
      post.save!
    end
  end

  def self.get_posts(page_id)
    if Page.find_by(page_id: page_id)
      page = Page.find_by(page_id: page_id)

      uri = URI.parse("https://graph.facebook.com/v3.0/#{page.page_id}/feed?fields=id,message,is_published,description,link,status_type,type,full_picture,name,story,from,created_time&limit=25&access_token=#{page.oauth_token}")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)
      unless data["error"]
        data["data"].each do |obj|
          caption = obj["name"] if obj["name"]
          description = obj["description"] if obj["description"]
          link = obj["link"] if obj["link"]
          published = obj["is_published"]
          from = obj["from"] if obj["from"]["id"] != page.page_id
          platform = "facebook"

          post = create_post(page.id, obj["id"], obj["message"], caption, description, link, obj["full_picture"], obj["type"], obj["created_time"], published, page.post_echo, from, platform)

          if post
            Comment.get_new_comments(post.id, page.oauth_token)
          end
        end
      end
    end
  end

  def self.get_instagram_post(page_id, post_id)
    page = Page.find_by(id: page_id)
    user_token = page.user.oauth_token

    uri = URI.parse("https://graph.facebook.com/v3.1/#{post_id}?fields=caption,media_url,media_type,owner,permalink,username,timestamp&access_token=#{user_token}")
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    if data
      page_id = page.id
      caption = data["caption"]
      link = data["permalink"]
      image = data["media_url"]
      type = data["media_type"].downcase
      fb_created = data["timestamp"]
      from = data["owner"]
      platform = "instagram"
      
      create_post(page_id, post_id, message=nil, caption, description=nil, link, image, type, fb_created, published=true, echo=true, from, platform)
    end
  end

  def self.get_single_post(page_id, post_id)
    page = Page.find_by(id: page_id)

    uri = URI.parse("https://graph.facebook.com/v3.0/#{post_id}?fields=id,message,is_published,description,link,status_type,type,full_picture,name,story,from,created_time&access_token=#{page.oauth_token}")
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    unless data["error"]
      caption = data["name"] if data["name"]
      description = data["description"] if data["description"]
      link = data["link"] if data["link"]
      published = data["is_published"]
      from = data["from"] if data["from"]["id"] != page.page_id
      platform = "facebook"

      create_post(page.id, data["id"], data["message"], caption, description, link, data["full_picture"], data["type"], data["created_time"], published, page.post_echo, from, platform)
    end
  end

  def self.get_posts_count(page_id)
    if Page.find_by(page_id: page_id)
      page = Page.find_by(page_id: page_id)
      posts_total = page.posts.count
      posts_echo = page.posts.where(:echo => true).count

      return {"total": posts_total, "echo": posts_echo}
    end
  end
end
