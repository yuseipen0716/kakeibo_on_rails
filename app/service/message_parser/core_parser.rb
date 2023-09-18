module MessageParser
  class CoreParser
    class << self
      # messageを受け取り、parsed_messageを返す。
      def handle_parser(message, message_type)
        # 使用するParserをhandle
        "message.split('\n'): #{message.split("\n")}, message_type: #{message_type}"
      end
    end
  end
end
