class AddPerspectiveToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :perspective, :json
  end
end
