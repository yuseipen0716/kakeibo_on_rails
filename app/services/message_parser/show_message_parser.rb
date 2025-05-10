module MessageParser
  class ShowMessageParser
    ERROR_TYPE = {
      MONTH: :month_specification_error,
      CATEGORY: :category_not_found
    }.freeze

    class << self
      def perform(message:, user:)
        # 一旦、今月の合計（総計または費目指定）を返す機能のみ実装する。
        # [TODO] 今後はこの部分はUsecaseに切り出したい。
        perform_monthly_total(message:, user:)
      end

      # 今月の家計簿データの合計
      # <確認したい月の指定>\n費目（未指定、または合計の場合は当該月の合計を返す）
      # params: message: String <"Month\nCategory">, user: User
      # month => '今月', '先月'または'2023-10'のような指定を要求。
      # category => Categoryとして保存されているもの。指定したcategoryが存在しない場合は、
      # 費目が見つからなかった旨のメッセージ返す。
      def perform_monthly_total(message:, user:)
        lines = message.split("\n")
        period = parse_period(lines.first)
        category = lines[1]

        return error_message(ERROR_TYPE[:MONTH]) unless month_specification_valid?(lines.first)
        return error_message(ERROR_TYPE[:CATEGORY]) if category_not_found?(category)

        # '月の合計を返す'
        GetMonthlyTotalUsecase.new(user:, period:, category:).perform
      end

      def error_message(error_type)
        case error_type.to_sym
        when :month_specification_error
          month_specification_error_message
        when :category_not_found
          category_not_found_message
        else
          "エラーが発生しました。\n時間をおいて、再度お試しください。"
        end
      end

      private

      # start..endを返す
      def parse_period(str)
        return error_message(ERROR_TYPE[:MONTH]) unless month_specification_valid?(str)

        if str == "今月"
          start_of_period = Time.zone.now.beginning_of_month
          end_of_period = Time.zone.now.end_of_day
        end

        if str == "先月"
          start_of_period = Time.zone.now.last_month.beginning_of_month
          end_of_period = Time.zone.now.last_month.end_of_month.end_of_day
        end

        if str.match?(/\A\d{4}-\d{2}\z/)
          start_of_period = Time.zone.strptime(str, "%Y-%m")
          end_of_period = start_of_period.end_of_month.end_of_day
        end
        start_of_period..end_of_period
      end

      def month_specification_valid?(str)
        str == "今月" || str == "先月" || str.match?(/\A\d{4}-\d{2}\z/)
      end

      def month_specification_error_message
        error_message = <<~ERROR
          期間（月）の指定方法が正しくありません。

          ------------
          今月
          食費
          ------------

          または

          ------------
          2023-10
          合計
          ------------

          のように指定してください。
        ERROR

        error_message.chomp
      end

      def category_not_found?(category)
        # 期間のみ入力されて費目の指定がない場合、費目の部分に合計と書かれた場合は除外
        category && category != "合計" && !Category.find_by(name: category)
      end

      def category_not_found_message
        error_message = <<~ERROR
          入力いただいた費目が見つかりませんでした。

          入力内容をご確認ください。
        ERROR

        error_message.chomp
      end
    end
  end
end
