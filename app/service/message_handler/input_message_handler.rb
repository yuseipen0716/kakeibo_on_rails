module MessageHandler
  class InputMessageHandler
    MESSAGE_TYPE = :input.freeze

    class << self
      # rubocop:disable Metrics/MethodLength
      def set_input_first_message
        message = "トークモード: #{User.human_attribute_name('talk_mode.input_mode')}\n"
        message << "---------------------------------\n"
        first_message = <<~INPUT
          家計簿データを入力する場合は、

          費目
          金額（半角数字）
          備考（任意）

          の形で入力してください。
          金額部分には「円」などの表記は不要です。

          誤って入力してしまった場合\n「とりけし」と入力することで、直前の家計簿データを削除することができます。
        INPUT
        message << first_message

        message.chomp
      end
      # rubocop:enable Metrics/MethodLength

      def perform(user, message)
        MessageParser::CoreParser.handle_parser(
          message: message,
          message_type: MESSAGE_TYPE,
          user: user
        )
      end
    end
  end
end