module MessageHandler
  class CoreHandler
    BUILT_IN_MESSAGE = {
      INPUT: '家計簿データ入力',
      SHOW: '家計簿データ確認',
      GROUP: 'グループ作成・参加',
      HELP: 'ヘルプ'
    }.freeze
    class << self
      # messageを受け取り、適切な処理に振り分け、replyを返す
      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      def perform(message, line_id)
        current_user = User.find_by(line_id:)
        case message
        when BUILT_IN_MESSAGE[:INPUT]
          current_user.update!(talk_mode: :input_mode) && MessageHandler::InputMessageHandler.set_input_first_message
        when BUILT_IN_MESSAGE[:SHOW]
          current_user.update(talk_mode: :show_mode) && set_show_mode_message
        when BUILT_IN_MESSAGE[:GROUP]
          current_user.update(talk_mode: :group_mode) && set_group_mode_message
        when BUILT_IN_MESSAGE[:HELP]
          set_help_message(current_user.talk_mode.to_sym)
        else
          handle_other_message(current_user, message)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
  
      private

      def set_show_mode_message
        message = "トークモード: #{User.human_attribute_name('talk_mode.show_mode')}\n"
        message << "---------------------------------\n"
        first_message = <<~SHOW
          当機能はまだリリース前です。
          もうしばらくお待ちください。
        SHOW
        message << first_message
  
        message.chomp
      end
  
      def set_group_mode_message
        message = "トークモード: #{User.human_attribute_name('talk_mode.group_mode')}\n"
        message << "--------------------------------------\n"
        message << "グループを新しく作成する場合は「作成」と入力してください。\nグループに参加する場合は「参加」と入力してください。\n"
  
        message.chomp
      end
  
      def set_help_message(talk_mode)
        case talk_mode
        when :default_mode
          message = <<~HELP
            【ヘルプ】\n
            当機能はまだリリース前です。
            これはヘルプメッセージです。
            これはヘルプメッセージです。
          HELP
          message.chomp
        when :input_mode
          MessageHandler::InputMessageHandler.set_input_first_message
        when :show_mode
          '確認モードのヘルプメッセージ'
        when :group_mode
          'グループモードのヘルプメッセージ'
        end
      end
  
      def handle_other_message(user, message)
        case user.talk_mode.to_sym
        when :input_mode
          MessageHandler::InputMessageHandler.perform(user, message)
        when :show_mode
          'handle_other_show'
        when :group_mode
          'handle_other_group'
        else
          '不明なメッセージ'
        end
      end
    end
  end
end
