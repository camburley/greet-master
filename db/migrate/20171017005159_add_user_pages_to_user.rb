class AddUserPagesToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :user_pages, :json, default: []
  end
end
