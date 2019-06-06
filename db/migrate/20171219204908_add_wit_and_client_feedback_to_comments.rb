class AddWitAndClientFeedbackToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :wit_object, :json
    add_column :comments, :client_flag, :string
  end
end
