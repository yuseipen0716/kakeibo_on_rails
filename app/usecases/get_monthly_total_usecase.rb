class GetMonthlyTotalUsecase
  # category: Categoryレコードのnameか、'合計'が入る。nilの場合もあり。
  def initialize(user:, period:, category: nil)
    @user = user
    @period = period
    @category = category
  end

  def perform
    # group機能は未実装なため、一旦user自体の家計簿データの合計を返す。
    total = if @category && @category != '合計'
              ExpenseRecord.eager_load(:category)
                           .active
                           .expense
                           .where(user: @user, transaction_date: @period)
                           .where(categories: { name: @category })
                           .sum(:amount)
            else
              # 費目の指定がない場合は、userのExpenseRecordsの合計を返す
              @user.expense_records.active.expense.where(transaction_date: @period).sum(:amount)
            end
    "#{total}円ナリ"
  end
end
