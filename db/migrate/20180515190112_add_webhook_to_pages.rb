class AddWebhookToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :webhook, :boolean, default: false
  end
end
