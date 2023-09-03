class CreateExpenseRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :expense_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :expense_type, null: false, default: 0
      t.integer :amount, null: false
      t.datetime :transaction_date, null: false
      t.text :memorandum

      t.timestamps
    end
  end
end
