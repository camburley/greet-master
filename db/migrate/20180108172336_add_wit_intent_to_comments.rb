class AddWitIntentToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :intent, :string
  end
end
