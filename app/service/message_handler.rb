class MessageHandler
  class << self
    # messageを受け取り、適切な処理に振り分け、replyを返す
    def perform(message)
      # 一旦動作確認のため、messageをそのまま返す
      return message
    end
  end
end
