class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|

      t.string :name
      t.string :email
      t.string :phone
      t.string :code
      t.string :logo_url

      t.timestamps
    end
  end
end
