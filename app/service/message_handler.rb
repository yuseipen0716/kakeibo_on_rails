class MessageHandler
  BUILT_IN_MESSAGE = {
    INPUT: '家計簿データ入力',
    SHOW: '家計簿データ確認',
    GROUP: 'グループ作成・参加',
    HELP: 'ヘルプ'
  }.freeze
  class << self
    # messageを受け取り、適切な処理に振り分け、replyを返す
    def perform(message)
      case message
      when BUILT_IN_MESSAGE[:INPUT]
        return 'にゅうりょく'
      when BUILT_IN_MESSAGE[:SHOW]
        return 'かくにん'
      when BUILT_IN_MESSAGE[:GROUP]
        return 'ぐるーぷ'
      when BUILT_IN_MESSAGE[:HELP]
        return 'へるぷ'
      else
        return '不明なメッセージ'
      end
    end
  end
end
