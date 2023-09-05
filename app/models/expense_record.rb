class ExpenseRecord < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum type: {
    expense: 0,
    income: 1
  }
end
