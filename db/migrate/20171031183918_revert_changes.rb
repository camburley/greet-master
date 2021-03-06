class RevertChanges < ActiveRecord::Migration[5.1]
  def change
  	change_column :comments, :echo_reactions, :json, default: {"like"=>"0", "love"=>"0", "haha"=>"0", "wow"=>"0", "sad"=>"0", "angry"=>"0"}
  	change_column :comments, :reactions, :json, default: {"like": "0", "love": "0", "haha": "0", "wow": "0", "sad": "0", "angry": "0"}
  	change_column :pages, :echo_response, :json, default: {"thanks": [], "reactions": {"like": [], "love": [], "haha": [], "wow": [], "sad": [], "angry": []}}
  	change_column :users, :user_pages, :json, default: []
  end
end
