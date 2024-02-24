class GetMonthlyTotalUsecase
  # category: Categoryレコードのnameか、'合計'が入る。nilの場合もあり。
  def initialize(user:, period:, category: nil)
    @user = user
    @period = period
    @category = category
  end

  def perform
    # group機能は未実装なため、一旦user自体の家計簿データの合計を返す。
    message = ''

    case @category
    when nil
      message = monthly_total_group_by_category_name
    when '合計'
      message = monthly_total
    else
      message = monthly_total_of_the_category
    end

    message
  end

  private

  # 費目の指定がない場合は、userのExpenseRecordsの合計を返す
  def monthly_total
    total = @user.expense_records.active.expense.where(transaction_date: @period).sum(:amount)
    "#{formatted_year_month}の#{@category}\n\n#{total}円ナリ"
  end

  # @categoryの@periodにおける合計金額を返す
  def monthly_total_of_the_category
    total = ExpenseRecord.eager_load(:category)
                         .active
                         .expense
                         .where(user: @user, transaction_date: @period)
                         .where(categories: { name: @category })
                         .sum(:amount)

    "#{formatted_year_month}の#{@category}\n\n#{total}円ナリ"
  end

  # @periodにおける費目ごとの合計金額を返す
  def monthly_total_group_by_category_name
    expenses_by_category_name = @user.expense_records
                                     .active
                                     .expense
                                     .where(transaction_date: @period)
                                     .joins(:category)
                                     .group('categories.name')
                                     .sum(:amount)

    expense_messages = expenses_by_category_name.map do |category_name, total|
      "#{category_name}: #{total}円"
    end

    # 返却するメッセージの1行目をここで用意
    # 2行目は空行を出力したいため、空文字の要素を置いておく。
    head_message = ["#{formatted_year_month}の費目別合計", ""]

    # 先頭に表示するメッセージに、各費目ごとのメッセージの配列を合わせて、join
    (head_message + expense_messages).join("\n")
  end

  def formatted_year_month
    @period.begin.strftime("%Y年%m月")
  end
end
