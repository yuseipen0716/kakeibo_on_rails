module MessageParser
  class InputMessageParser
    CANCEL_WORDS = %w[とりけし 取り消し 取消 トリケシ].freeze
    HELP_WORDS = %w[へるぷ ヘルプ help HELP Help].freeze

    class << self
      def perform(message:, user:)
        # :input_mode, :expense_input_mode, :income_input_mode
        current_talk_mode = user.talk_mode.to_sym

        case current_talk_mode
        when :input_mode
          perform_input_mode(message: message, user: user)
        when :expense_input_mode
          perform_expense_or_income(message: message, user: user)
        when :income_input_mode
          perform_expense_or_income(message: message, user: user)
        end
      end

      # message => 入力する家計簿データが支出か収入かを聞いた後のメッセージ
      # current_talk_mode => :input_mode
      def perform_input_mode(message:, user:)
        lines = message.split("\n")
        top_line_message = lines.first # 支出 or 収入

        if expense?(top_line_message)
          user.update(talk_mode: :expense_input_mode)

          # 支出入力依頼メッセージ
          return request_expense_or_income_data(user.talk_mode)
        end

        if income?(top_line_message)
          user.update(talk_mode: :income_input_mode)

          # 収入入力依頼メッセージ
          return request_expense_or_income_data(user.talk_mode)
        end

        # 受け取ったメッセージが「支出」でも「収入」でもなかった場合
        user.update(talk_mode: :default_mode)
        return "メッセージの形式が正しくありません。\nもう一度最初から操作を行ってください。"
      end

      def perform_expense_or_income(message:, user:)
        # parsed_message_hash: { category: category, amount: amount, memorandum: memorandum, transaction_date: transaction_date }
        parsed_message_hash = parse_message(message)

        # 家計簿入力用のメッセージに不備がある場合は、エラーメッセージを配列に入れて返す
        check_result_messages = check_input_message(parsed_message_hash)
        return generate_error_message(check_result_messages) unless check_result_messages.empty?

        # 家計簿データの入力処理を行い、その結果をメッセージで返す。
        "家計簿データの登録を始めます。トークモード: #{User.human_attribute_name("talk_mode.#{user.talk_mode}")}" # test_message
      end

      def request_expense_or_income_data(talk_mode)
        talk_mode = talk_mode.to_s unless talk_mode.is_a?(String)
        message = "トークモード: #{User.human_attribute_name("talk_mode.#{talk_mode}")}\n"
        message << "---------------------------------\n"
        request_message = <<~INPUT
          家計簿データを入力する場合は、

          費目
          金額（半角数字。単位は不要）
          備考（任意）
          日付 (任意 例: 2023-08-08)

          の形で入力してください。
          金額部分には「円」などの表記は不要です。

          入力例
          ---------------------------------
          食費
          1000
          コンビニ
          2023-09-12
        INPUT

        message << request_message
        message.chomp
      end

      def generate_error_message(error_messages)
        error_message = error_messages.join("\n") + "\n\n"
        input_example = <<~EXAMPLE
          入力例
          ---------------------------------
          食費
          1000
          コンビニ
          2023-09-12
        EXAMPLE

        error_message << input_example
        error_message.chomp
      end

      private

      # return error_messages: string[]
      # params lines: string[]
      def check_input_message(message_hash)
        error_messages = []
        error_messages << '費目の入力は必須です。' if message_hash[:category].empty? # ないと思うけど。
        error_messages << '金額の入力は必須です。' if message_hash[:amount].empty?
        error_messages << '費目は10文字以内で設定してください。' if message_hash[:category].length > 10
        error_messages << '金額は半角数字で入力してください。円などの単位も不要です。' unless message_hash[:amount].empty? || message_hash[:amount].match?(/\A\d+\z/)
        error_messages << '入力された日付の値が不正です。' unless is_date?(message_hash[:transaction_date])
        error_messages
      end

      def expense?(message)
        message.match?(/支出/)
      end

      def income?(message)
        message.match?(/収入/)
      end

      def normalize_dash(str = nil)
        # 入力時の変換によって、ハイフンに表記のブレが生じたため、normalizeしたい
        str&.gsub(/[‐－–—]/, '-')
      end

      def is_date?(str)
        # 基本的には2023-09-09のようなフォーマットでとりたいが、20230909の表記ゆれは許容する
        str.match?(/\A\d{4}-\d{2}-\d{2}\z/) || str.match?(/\A\d{8}\z/)
      end

      # params message:
      # 食費 (require)
      # 1000 (require)
      # コンビニ
      # 2023-09-20
      # return { category: string, amount: string, memorandum: string, transaction_date: string }
      def parse_message(message)
        lines = message.split("\n").slice(0..3)

        category = lines[0]
        amount = lines[1]
        memorandum = lines[2]
        transaction_date = normalize_dash(lines[3])

        if lines.length == 3
          if is_date?(normalize_dash(lines[2]))
            # messageの3行目が日付のデータであった場合
            memorandum = ''
            transaction_date = normalize_dash(lines[2])
          else
            # messageの3行目が日付データでなかった場合
            memorandum = lines[2]
          end
        end

        {
          category: category || '',
          amount: amount || '',
          memorandum: memorandum || '',
          transaction_date: transaction_date || Time.zone.today.to_date.to_s
        }
      end
    end
  end
end