# == Schema Information
#
# Table name: expense_records
#
#  id               :integer          not null, primary key
#  amount           :integer          not null
#  expense_type     :integer          default("expense"), not null
#  is_disabled      :boolean          default(FALSE), not null
#  memorandum       :text
#  transaction_date :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :integer          not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_expense_records_on_category_id  (category_id)
#  index_expense_records_on_user_id      (user_id)
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#  user_id      (user_id => users.id)
#
class ExpenseRecord < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum expense_type: {
    expense: 0,
    income: 1
  }

  scope :active, -> { where(is_disabled: false) }
  scope :expense, -> { where(expense_type: :expense) }
  scope :income, -> { where(expense_type: :income) }
end
