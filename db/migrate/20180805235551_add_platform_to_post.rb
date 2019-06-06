class AddPlatformToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :platform, :string
  end
end
