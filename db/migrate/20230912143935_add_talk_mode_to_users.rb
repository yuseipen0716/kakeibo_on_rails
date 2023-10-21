class AddTalkModeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :talk_mode, :integer, default: 0, null: false
  end
end
