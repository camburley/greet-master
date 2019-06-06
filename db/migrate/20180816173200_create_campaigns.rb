class CreateCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :campaigns do |t|
      t.belongs_to :page
      t.string :title
      t.json :compare, default: []
      t.json :tags, default: []

      t.timestamps
    end
  end
end
