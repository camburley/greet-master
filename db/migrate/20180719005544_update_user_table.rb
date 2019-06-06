class UpdateUserTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :company_id, :integer
    remove_column :users, :page_selected, :integer
    remove_column :users, :user_pages, :json
  end
end
