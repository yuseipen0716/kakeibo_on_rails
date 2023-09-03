class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
