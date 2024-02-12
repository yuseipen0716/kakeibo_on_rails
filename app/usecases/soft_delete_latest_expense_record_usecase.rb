class SoftDeleteLatestExpenseRecordUsecase
  def initialize(user)
    @user = user
    @latest_expense_record = user.expense_records.last
  end

  def perform
    @latest_expense_record.update(is_disabled: true)

    response_message = <<~MESSAGE
      以下の家計簿データを取り消しました💡

      費目: #{@latest_expense_record.category.name}
      金額: #{@latest_expense_record.amount}
      備考: #{@latest_expense_record.memorandum.present? ? @latest_expense_record.memorandum : ''}
      日付: #{@latest_expense_record.transaction_date.to_date}
    MESSAGE

    response_message.chomp
  rescue ActiveRecord::RecordInvalid => e
    e.message
  end
end
