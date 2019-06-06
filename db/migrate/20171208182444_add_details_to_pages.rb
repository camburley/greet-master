class AddDetailsToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :caption, :string
    add_column :posts, :description, :string
    add_column :posts, :link, :string
    add_column :posts, :published, :boolean, default: false
  end
end
