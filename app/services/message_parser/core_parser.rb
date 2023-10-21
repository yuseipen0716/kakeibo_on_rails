module MessageParser
  class CoreParser
    class << self
      # messageを受け取り、parsed_messageを返す。
      # params: message:string, message_type:Symbol :input | :show | :group
      def handle_parser(message:, message_type:, user:)
        # 使用するParserをhandle
        case message_type
        when :input
          MessageParser::InputMessageParser.perform(message:, user:)
        when :show
          'MessageParser::ShowMessageParser'
        when :group
          'MessageParser::GroupMessageParser'
        else
          'other message'
        end
      end
    end
  end
end
