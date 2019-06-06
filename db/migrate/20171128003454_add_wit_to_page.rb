class AddWitToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :wit_token, :string
    add_column :pages, :wit_app, :string
  end
end
