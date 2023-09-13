class MessageHandler
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
        current_user.update!(talk_mode: :input_mode) && set_input_mode_message
      when BUILT_IN_MESSAGE[:SHOW]
        current_user.update(talk_mode: :show_mode) && set_show_mode_message
      when BUILT_IN_MESSAGE[:GROUP]
        current_user.update(talk_mode: :group_mode) && set_group_mode_message
      when BUILT_IN_MESSAGE[:HELP]
        set_help_message
      else
        handle_other_message
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    # rubocop:disable Metrics/MethodLength
    def set_input_mode_message
      message = "トークモード: #{User.human_attribute_name('talk_mode.input_mode')}\n"
      message << "---------------------------------\n"
      first_message = <<~INPUT
        家計簿データを入力する場合は、

        費目
        金額（半角数字）
        備考（任意）

        の形で入力してください。
        金額部分には「円」などの表記は不要です。

        誤って入力してしまった場合、「とりけし」と入力することで、直前の家計簿データを削除することができます。
      INPUT
      message << first_message

      message.chomp
    end
    # rubocop:enable Metrics/MethodLength

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

    def set_help_message
      message = <<~HELP
        【ヘルプ】\n
        これはヘルプメッセージです。
        これはヘルプメッセージです。
      HELP

      message.chomp
    end

    def handle_other_message
      '不明なメッセージ'
    end
  end
end
