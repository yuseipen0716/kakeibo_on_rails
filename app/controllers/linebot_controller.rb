class LinebotController < ApplicationController
  require 'line/bot'

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    # LINEからのリクエストの検証
    unless client.validate_signature(body, signature)
      return render plain: 'Bad Request', status: 400
    end

    events = client.parse_events_from(body)

    # line-bot-apiで解析されたeventの処理。
    # 一旦message eventのみ対応。
    events.each do |event|
      if event.is_a?(Line::Bot::Event::Message)
        parsed_message = MessageParser.parse(event.message['text'])
        reply_text = MessageHandler.perform(parsed_message)

        message = {
          type: 'text',
          text: reply_text
        }
        client.reply_message(event['replyToken'], message)
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
