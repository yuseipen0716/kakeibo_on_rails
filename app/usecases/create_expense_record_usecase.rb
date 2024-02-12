class CreateExpenseRecordUsecase
  class << self
    def perform(expense_record_attrs:, expense_type:, user:)
      ActiveRecord::Base.transaction do
        record = user.expense_records.new

        # Categoryモデルにない費目だったら、新規作成
        category = Category.find_or_create_by(name: expense_record_attrs[:category])

        expense_record_attrs.delete(:category)
        expense_record_attrs[:expense_type] = expense_type
        expense_record_attrs[:category_id] = category.id

        record.assign_attributes(expense_record_attrs)

        begin
          record.save!

          response_message = <<~MESSAGE
            #{expense_type == :expense ? '支出' : '収入'}データの登録に成功しました💡

            費目: #{record.category.name}
            金額: #{record.amount}
            備考: #{record.memorandum.present? ? record.memorandum : ''}
            日付: #{record.transaction_date.to_date}

            #{expense_type == :expense ? '支出' : '収入'}データを続けて入力する場合は、このまま続けて入力できます。

            #{expense_type == :expense ? '収入' : '支出'}データを入力する場合は、#{expense_type == :expense ? '収入' : '支出'}データ入力のメニューをタップしてください。

            入力したデータを取り消したい場合は、「とりけし」と入力してください。
          MESSAGE

          response_message.chomp
        rescue ActiveRecord::RecordInvalid => e
          e.message
          # record.errors.full_messages.join("\n")
        end
      end
    end
  end
end
