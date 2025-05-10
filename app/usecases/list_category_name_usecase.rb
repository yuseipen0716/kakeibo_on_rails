class ListCategoryNameUsecase
  def initialize(user)
    @user = user
  end

  # userのtalk_modeに応じて、これまで使用したことのある費目を返す
  def perform
    records = expense_or_income_records
    return [] if records.blank?

    category_ids = records.pluck(:category_id).uniq
    Category.where(id: category_ids).pluck(:name)
  end

  private

  def expense_or_income_records
    # 直近5か月で入力した費目のみ取得するようにしてみる。
    records = ExpenseRecord.active.where(user_id: @user.id, created_at: 5.months.ago..)
    @user.talk_mode == "income_input_mode" ? records.income : records.expense
  end
end
