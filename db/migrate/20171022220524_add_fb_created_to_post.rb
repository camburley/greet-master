class AddFbCreatedToPost < ActiveRecord::Migration[5.1]
  def change
  	add_column :posts, :fb_created, :datetime
  end
end
