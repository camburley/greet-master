class AddEchoResEchoIdToComments < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :echo_reactions, :json, default: {"like": "0", "love": "0", "haha": "0", "wow": "0", "sad": "0", "angry": "0"}
  	add_column :comments, :echo_id, :string
  end
end
