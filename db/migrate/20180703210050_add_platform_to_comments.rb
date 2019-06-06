class AddPlatformToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :platform, :string
  end
end
