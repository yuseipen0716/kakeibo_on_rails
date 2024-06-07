class ListCategoryNameUsecase
  def initialize(user)
    @user = user
  end

  # userのtalk_modeに応じて、これまで使用したことのある費目を返す
  def perform
    records = expense_or_income_records
    return [] if records.blank?

    category_ids = records.pluck(:category_id)
    Category.where(id: category_ids)
  end

  private

  def expense_or_income_records
    records = ExpenseRecord.active
    @user.talk_mode == 'income_input_mode' ? records.income : records.expense
  end
end
