class LinebotController < ApplicationController
  require "line/bot"

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    # LINEからのリクエストの検証
    return render plain: "Bad Request", status: 400 unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)

    # line-bot-apiで解析されたeventの処理。
    # 一旦message eventのみ対応。
    events.each do |event|
      next unless event.is_a?(Line::Bot::Event::Message)

      line_id = event["source"]["userId"]
      if new_user?(line_id)
        user_name = get_user_name(line_id)
        CreateUserUsecase.perform(line_id, user_name)
      end

      reply_text = MessageHandler::CoreHandler.perform(event.message["text"], line_id)

      message = {
        type: "text",
        text: reply_text
      }
      client.reply_message(event["replyToken"], message)
    end

    head :ok
  end
  # rubocop:enable Metrics/AbcSize

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end

  def new_user?(line_id)
    !User.find_by(line_id:)
  end

  def get_user_name(line_id)
    response = client.get_profile(line_id)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)["displayName"]
    else
      Rails.logger.error("Failed to fetch user name for user_id: #{line_id}. Response: #{response.body}")
      nil
    end
  end
end
