class AddMentionsToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :mention, :boolean, default: false
  end
end
