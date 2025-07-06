module MessageHandler
  class CoreHandler
    BUILT_IN_MESSAGE = {
      INPUT: "家計簿データ入力",
      EXPENSE_INPUT: "支出データ入力",
      INCOME_INPUT: "収入データ入力",
      SHOW: "家計簿データ確認",
      GROUP: "グループ作成・参加",
      HELP: "ヘルプ"
    }.freeze
    class << self
      # messageを受け取り、適切な処理に振り分け、replyを返す
      # rubocop:disable Metrics/CyclomaticComplexity
      def perform(message, line_id)
        current_user = User.find_by(line_id:)
        case message
        when BUILT_IN_MESSAGE[:INPUT]
          current_user.update(talk_mode: :input_mode) && MessageHandler::InputMessageHandler.input_first_message
        when BUILT_IN_MESSAGE[:EXPENSE_INPUT]
          current_user.update(talk_mode: :expense_input_mode) && MessageHandler::InputMessageHandler.expense_input_first_message
        when BUILT_IN_MESSAGE[:INCOME_INPUT]
          current_user.update(talk_mode: :income_input_mode) && MessageHandler::InputMessageHandler.income_input_first_message
        when BUILT_IN_MESSAGE[:SHOW]
          current_user.update(talk_mode: :show_mode) && MessageHandler::ShowMessageHandler.show_first_message
        when BUILT_IN_MESSAGE[:GROUP]
          handle_group_entry(current_user)
        when BUILT_IN_MESSAGE[:HELP]
          current_user.update(talk_mode: :default_mode) && help_message(current_user.talk_mode.to_sym)
        else
          handle_other_message(current_user, message)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def handle_group_entry(user)
        if user.group.present?
          user.update(talk_mode: :group_leaving_confirmation_mode)
          MessageHandler::GroupMessageHandler.group_leaving_confirmation_message(user)
        else
          user.update(talk_mode: :group_mode)
          group_mode_message
        end
      end

      def group_mode_message
        message = "トークモード: #{User.human_attribute_name("talk_mode.group_mode")}\n"
        message << "--------------------------------------\n"
        message << "グループを新しく作成する場合は「作成」と入力してください。\nグループに参加する場合は「参加」と入力してください。\n"

        message.chomp
      end

      def help_message(talk_mode)
        case talk_mode
        when :default_mode
          message = <<~HELP
            【ヘルプ】

            このボットは家計簿の管理をサポートします。

            ■基本機能
            • 支出・収入データの入力
            • 家計簿データの確認
            • グループでの家計簿共有

            ■使用方法
            以下のメッセージを送信してください：

            📝 「家計簿データ入力」
            　→ 支出・収入データを入力できます

            📊 「家計簿データ確認」
            　→ 入力済みデータの確認・集計ができます

            👥 「グループ作成・参加」
            　→ 家族や友人とデータを共有できます

            ❓ 「ヘルプ」
            　→ このヘルプメッセージを表示します

            ■直接入力も可能
            • 「支出データ入力」で支出入力モードに
            • 「収入データ入力」で収入入力モードに

            何かご不明な点がございましたら、上記のメニューから該当する機能をお試しください。
          HELP
          message.chomp
        when :input_mode
          MessageHandler::InputMessageHandler.input_first_message
        when :show_mode
          "確認モードのヘルプメッセージ"
        when :group_mode
          "グループモードのヘルプメッセージ"
        end
      end

      def handle_other_message(user, message)
        case user.talk_mode.to_sym
        when :input_mode, :expense_input_mode, :income_input_mode
          MessageHandler::InputMessageHandler.perform(user, message)
        when :show_mode
          MessageHandler::ShowMessageHandler.perform(user, message)
        when :group_mode, :group_creating_mode, :group_joining_mode, :group_leaving_confirmation_mode
          MessageHandler::GroupMessageHandler.perform(user, message)
        else
          "不明なメッセージ"
        end
      end
    end
  end
end
