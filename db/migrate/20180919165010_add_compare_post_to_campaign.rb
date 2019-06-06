class AddComparePostToCampaign < ActiveRecord::Migration[5.1]
  def change
    add_column :campaigns, :compare_post, :json, default: []
  end
end
