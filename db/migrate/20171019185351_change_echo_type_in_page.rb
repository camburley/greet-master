class ChangeEchoTypeInPage < ActiveRecord::Migration[5.1]
  def change
  	add_column :pages, :post_echo, :boolean, default: true
  end
end
