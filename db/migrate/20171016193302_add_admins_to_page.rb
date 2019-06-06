class AddAdminsToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :token_expire, :string
  end
end
