module MessageHandler
  class InputMessageHandler
    MESSAGE_TYPE = :input

    class << self
      def perform(user, message)
        return input_first_message if user.talk_mode == :input && message == MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:INPUT]

        MessageParser::CoreParser.handle_parser(
          message:,
          message_type: MESSAGE_TYPE,
          user:
        )
      end

      def input_first_message
        message = "トークモード: #{User.human_attribute_name('talk_mode.input_mode')}\n"
        message << "---------------------------------\n"
        # first_message = <<~INPUT
        #   家計簿データを入力する場合は、

        #   費目
        #   金額（半角数字）
        #   備考（任意）
        #   日付 (任意 例: 2023-08-08)

        #   の形で入力してください。
        #   金額部分には「円」などの表記は不要です。

        #   誤って入力してしまった場合\n「とりけし」と入力することで、直前の家計簿データを削除することができます。
        # INPUT
        first_message = <<~INPUT
          入力するのは支出ですか？収入ですか？

          支出であれば「支出」、収入であれば「収入」と入力してメッセージを送信してください。（「」は不要です。）
        INPUT
        message << first_message

        message.chomp
      end
    end
  end
end
