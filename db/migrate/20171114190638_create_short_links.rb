class CreateShortLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :short_links do |t|

      t.belongs_to :page
      t.string :name
      t.string :description
      t.string :image
      t.string :url
      t.string :slug
      t.integer :clicks, :default => 0

      t.timestamps
    end
  end
end
