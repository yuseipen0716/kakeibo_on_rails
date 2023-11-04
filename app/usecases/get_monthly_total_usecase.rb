class GetMonthlyTotalUsecase
  class << self
    def perform(user:, period:, category: nil)
      # group機能は未実装なため、一旦user自体の家計簿データの合計を返す。
      total = if category
                ExpenseRecord.eager_load(:category)
                             .where(user:, transaction_date: period)
                             .where(categories: { name: category })
                             .sum(:amount)
              else
                # 費目の指定がない場合は、userのExpenseRecordsの合計を返す
                user.expense_records.where(transaction_date: period).sum(:amount)
              end
      "#{total}円ナリ"
    end
  end
end
