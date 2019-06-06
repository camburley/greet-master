class AddFromUserToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :from_user, :json
  end
end
