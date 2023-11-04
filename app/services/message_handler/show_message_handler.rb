module MessageHandler
  class ShowMessageHandler
    MESSAGE_TYPE = :show
    # 家計簿データの取り消し機能を実装する場合は以下のコメントアウトを復活させる。
    # CANCEL_WORDS = %w[とりけし 取り消し 取消 トリケシ].freeze

    class << self
      def perform(user, message)
        return show_first_message if user.talk_mode == :show_mode && MessageHandler::CoreHnadler::BUILT_IN_MESSAGE[:SHOW]

        # レポート機能を実装するときは、messageに「レポート」などの文字列が含まれるかどうかをチェックし、
        # reportメソッド（まだ実装していない）を呼び出すようになる...?

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

          1. 合計の確認
          ------------
          今月
          食費（確認したい費目名）
          ------------

          または

          ------------
          2023-10
          合計（記載しなくてもよい）
          ------------

          のように入力してください。
        SHOW

        message << first_message
        message.chomp
      end
    end
  end
end
