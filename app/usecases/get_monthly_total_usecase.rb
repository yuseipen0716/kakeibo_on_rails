class GetMonthlyTotalUsecase
  # category: Categoryレコードのnameか、'合計'が入る。nilの場合もあり。
  def initialize(user:, period:, category: nil)
    @user = user
    @period = period
    @category = category
  end

  def perform
    # group機能は未実装なため、一旦user自体の家計簿データの合計を返す。

    case @category
    when nil
      monthly_total_group_by_category_name
    when "合計"
      monthly_total
    else
      monthly_total_of_the_category
    end
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
    personal_expenses = get_expenses_by_category_for_user(@user)

    group_expenses = if @user.group
                       group_members = @user.group.users
                       get_expenses_by_category_for_users(group_members)
                     else
                       {}
                     end

    format_combined_expenses_message(personal_expenses, group_expenses)
  end

  def get_expenses_by_category_for_user(user)
    user.expense_records
        .active
        .expense
        .where(transaction_date: @period)
        .joins(:category)
        .group("categories.name")
        .sum(:amount)
  end

  def get_expenses_by_category_for_users(users)
    ExpenseRecord.where(user: users)
                 .active
                 .expense
                 .where(transaction_date: @period)
                 .joins(:category)
                 .group("categories.name")
                 .sum(:amount)
  end

  def format_combined_expenses_message(personal_expenses, group_expenses)
    messages = ["#{formatted_year_month}の費目別合計", ""]

    # 個人の合計
    messages << "<個人>"
    if personal_expenses.any?
      personal_expenses.sort.each do |category_name, total|
        messages << "#{category_name}: #{total}円"
      end
    else
      messages << "データなし"
    end

    # グループの合計（グループに所属している場合のみ）
    if @user.group
      messages << ""
      messages << "<グループ>"
      if group_expenses.any?
        group_expenses.sort.each do |category_name, total|
          messages << "#{category_name}: #{total}円"
        end
      else
        messages << "データなし"
      end
    end

    messages.join("\n")
  end

  def formatted_year_month
    @period.begin.strftime("%Y年%m月")
  end
end
