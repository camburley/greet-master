class AddPageReactedToComment < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :team_reacted, :boolean, default: false
  end
end
