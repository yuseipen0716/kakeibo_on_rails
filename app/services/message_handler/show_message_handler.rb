module MessageHandler
  class ShowMessageHandler
    MESSAGE_TYPE = :show

    class << self
      def perform(user, message)
        return show_first_message if user.talk_mode == :show_mode && MessageHandler::CoreHnadler::BUILT_IN_MESSAGE[:SHOW]

        MessageParser::CoreParser.handle_parser(
          message:,
          message_type: MESSAGE_TYPE,
          user:
        )
      end

      def show_first_message
        message = "トークモード: #{User.human_attribute_name('talk_mode.show_mode')}\n"
        message << "---------------------------------\n"

        first_message = <<~SHOW
          入力済みの家計簿データを確認するモードです。
        SHOW

        message << first_message
        message.chomp
      end
    end
  end
end
