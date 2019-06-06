class AddFieldsToComments < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :echo_responed, :boolean, default: false
  	add_column :comments, :echo_message, :string
  	add_column :comments, :reactions, :json, default: []
  end
end
