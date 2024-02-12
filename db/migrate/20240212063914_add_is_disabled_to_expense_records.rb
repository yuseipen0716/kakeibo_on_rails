class AddIsDisabledToExpenseRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :expense_records, :is_disabled, :boolean, null: false, default: false
  end
end
