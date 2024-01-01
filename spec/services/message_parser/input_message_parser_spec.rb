require 'rails_helper'

RSpec.describe MessageParser::InputMessageParser do
  describe 'perform' do
    let(:usecase) { described_class.perform(message: message, user: user) }
    let(:user) { create(:user, talk_mode: talk_mode) }

    context 'when user.talk_mode is input_mode' do
      let(:talk_mode) { :input_mode }

      context 'when message is `支出`' do
        let(:message) { '支出' }
        let(:response_message) do
          <<~RESPONSE
            トークモード: 支出入力
            ---------------------------------
            家計簿データを入力する場合は、

            費目
            金額（半角数字。単位は不要）
            備考（任意）
            日付 (任意 例: 2023-08-08)

            の形で入力してください。
            金額部分には「円」などの表記は不要です。

            入力例
            ---------------------------------
            食費
            1000
            コンビニ
            2023-09-12
          RESPONSE
        end

        it 'returns expense_input description' do
          expect(usecase).to eq(response_message.chomp)
        end
      end

      context 'when message is `収入`' do
        let(:message) { '収入' }
        let(:response_message) do
          <<~RESPONSE
            トークモード: 収入入力
            ---------------------------------
            家計簿データを入力する場合は、

            費目
            金額（半角数字。単位は不要）
            備考（任意）
            日付 (任意 例: 2023-08-08)

            の形で入力してください。
            金額部分には「円」などの表記は不要です。

            入力例
            ---------------------------------
            食費
            1000
            コンビニ
            2023-09-12
          RESPONSE
        end

        it 'returns income_input description' do
          expect(usecase).to eq(response_message.chomp)
        end
      end

      context 'when message is not `支出` or `収入`' do
        let(:message) { 'あいう' }
        let(:response_message) { "メッセージの形式が正しくありません。\nもう一度最初から操作を行ってください。" }

        it 'returns error message' do
          expect(usecase).to eq(response_message)
        end

        it 'is changed talk_mode into default_mode' do
          usecase
          expect(user.talk_mode.to_sym).to eq(:default_mode)
        end
      end
    end

    context 'when user.talk_mode is expense_input_mode' do
      let(:talk_mode) { :expense_input_mode }
    end

    context 'when user.talk_mode is income_input_mode' do
      let(:talk_mode) { :income_input_mode }
    end
  end
end
