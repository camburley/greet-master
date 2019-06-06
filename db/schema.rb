# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180919165010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.bigint "page_id"
    t.string "title"
    t.json "compare", default: []
    t.json "tags", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.json "compare_post", default: []
    t.index ["page_id"], name: "index_campaigns_on_page_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id"
    t.string "sender_name"
    t.string "sender_id"
    t.string "comment_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "tags"
    t.boolean "echo_responded", default: false
    t.string "echo_message"
    t.json "reactions", default: {"like"=>"0", "love"=>"0", "haha"=>"0", "wow"=>"0", "sad"=>"0", "angry"=>"0"}
    t.json "echo_reactions", default: {"like"=>"0", "love"=>"0", "haha"=>"0", "wow"=>"0", "sad"=>"0", "angry"=>"0"}
    t.string "echo_id"
    t.boolean "team_responded", default: false
    t.string "user_feedback"
    t.string "wit_flag"
    t.json "wit_object"
    t.string "client_flag"
    t.string "intent"
    t.json "perspective"
    t.boolean "mention", default: false
    t.string "platform"
    t.boolean "team_reacted", default: false
    t.string "link"
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "code"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "category"
    t.string "page_id"
    t.string "oauth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "picture"
    t.boolean "echo"
    t.json "echo_response", default: {"thanks"=>[], "reactions"=>{"like"=>[], "love"=>[], "haha"=>[], "wow"=>[], "sad"=>[], "angry"=>[]}}
    t.string "token_expire"
    t.boolean "post_echo", default: true
    t.boolean "tag_response", default: true
    t.boolean "domain_block", default: false
    t.boolean "toxic_message", default: false
    t.boolean "webhook", default: false
    t.string "instagram_id"
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "page_id"
    t.string "post_id"
    t.string "image"
    t.string "message"
    t.boolean "echo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fb_created"
    t.string "post_type"
    t.string "caption"
    t.string "description"
    t.string "link"
    t.boolean "published", default: false
    t.json "from_user"
    t.string "platform"
    t.index ["page_id"], name: "index_posts_on_page_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "short_links", force: :cascade do |t|
    t.bigint "page_id"
    t.string "name"
    t.string "description"
    t.string "image"
    t.string "url"
    t.string "slug"
    t.integer "clicks", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_short_links_on_page_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "profile_pic"
    t.string "first_name"
    t.string "last_name"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
