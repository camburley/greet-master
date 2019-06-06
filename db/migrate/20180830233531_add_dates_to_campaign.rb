class AddDatesToCampaign < ActiveRecord::Migration[5.1]
  def change
    add_column :campaigns, :start_date, :datetime
    add_column :campaigns, :end_date, :datetime
  end
end
