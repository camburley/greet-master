class RemoveEchoTable < ActiveRecord::Migration[5.1]
  def change
    def down
      drop_table :echos
    end

    def up
      create_table :echos
    end
  end
end
