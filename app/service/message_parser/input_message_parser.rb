module MessageParser
  class InputMessageParser
    CANCEL_WORDS = %w[とりけし 取り消し 取消 トリケシ].freeze
    HELP_WORDS = %w[へるぷ ヘルプ help HELP Help].freeze

    class << self
      def perform(message:, user:)
        lines = message.split("\n")
        top_line_message = lines.first

        if CANCEL_WORDS.include?(top_line_message)
          # とりけし処理
          # current_userのもつ、最新の家計簿データを削除する処理を行い、その結果をmessageで返す
          return 'とりけし' # test_message
        end

        # 家計簿データの入力処理を行い、その結果をメッセージで返す。
        '家計簿データの登録を始めます。' # test_message
      end
    end
  end
end