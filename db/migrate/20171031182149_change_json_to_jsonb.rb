class ChangeJsonToJsonb < ActiveRecord::Migration[5.1]
  def change
  	change_column :comments, :echo_reactions, :jsonb, default: {"like"=>"0", "love"=>"0", "haha"=>"0", "wow"=>"0", "sad"=>"0", "angry"=>"0"}
  end
end
