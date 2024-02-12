class SoftDeleteLatestExpenseRecordUsecase
  def initialize(user)
    @user = user
    @latest_expense_record = user.expense_records.last
  end

  def perform
    p @latest_expense_record
    @latest_expense_record.update(is_disabled: true)
    p @latest_expense_record
  end
end
