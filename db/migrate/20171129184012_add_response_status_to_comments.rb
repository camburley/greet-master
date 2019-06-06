class AddResponseStatusToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :team_responded, :boolean, default: false
    add_column :comments, :user_feedback, :string
    add_column :comments, :wit_flag, :string
    rename_column :comments, :echo_responed, :echo_responded

    add_column :pages, :tag_response, :boolean, default: true
    add_column :pages, :domain_block, :boolean, default: false
    add_column :pages, :toxic_message, :boolean, default: false
  end
end
