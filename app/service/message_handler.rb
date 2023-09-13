class MessageHandler
  BUILT_IN_MESSAGE = {
    INPUT: '家計簿データ入力',
    SHOW: '家計簿データ確認',
    GROUP: 'グループ作成・参加',
    HELP: 'ヘルプ'
  }.freeze
  class << self
    # messageを受け取り、適切な処理に振り分け、replyを返す
    # rubocop:disable Metrics/MethodLength
    def perform(message, line_id)
      current_user = User.find_by(line_id:)
      case message
      when BUILT_IN_MESSAGE[:INPUT]
        current_user.update!(talk_mode: :input_mode)
        "トークモード: #{User.human_attribute_name('talk_mode.input_mode')}"
      when BUILT_IN_MESSAGE[:SHOW]
        current_user.update(talk_mode: :show_mode)
        "トークモード: #{User.human_attribute_name('talk_mode.show_mode')}"
      when BUILT_IN_MESSAGE[:GROUP]
        current_user.update(talk_mode: :group_mode)
        "トークモード: #{User.human_attribute_name('talk_mode.group_mode')}"
      when BUILT_IN_MESSAGE[:HELP]
        'へるぷ'
      else
        '不明なメッセージ'
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
