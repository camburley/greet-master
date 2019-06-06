class AddInstagramRemoveWit < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :instagram_id, :string
    remove_column :pages, :wit_token, :string
    remove_column :pages, :wit_app, :string
  end
end
