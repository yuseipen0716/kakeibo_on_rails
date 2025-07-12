require "rails_helper"

RSpec.describe MessageHandler::CoreHandler do
  describe "perform" do
    let(:result) { described_class.perform(message, line_id) }
    let(:user) { create(:user, line_id:) }
    let(:line_id) { "1234567890" }

    before { user }

    # 家計簿データ入力
    context "when input expense or income record" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:INPUT] }
      let(:response_message) do
        <<~RESPONSE
          トークモード: 入力
          ---------------------------------
          入力するのは支出ですか？収入ですか？

          支出であれば「支出」、収入であれば「収入」と入力してメッセージを送信してください。（「」は不要です。）
        RESPONSE
      end

      it "return input_first_message" do
        expect(result).to eq(response_message.chomp)
      end
    end

    # 支出データ入力
    context "when input expense orecord" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:EXPENSE_INPUT] }
      let(:response_message) do
        <<~RESPONSE
          トークモード: 支出入力
          ---------------------------------
          支出データを入力する場合は、

          費目
          金額（半角数字）
          備考（任意）
          日付 (任意 例: 2023-08-08)

          の形で入力してください。
          金額部分には「円」などの表記は不要です。

          誤って入力してしまった場合
          「とりけし」と入力することで、直前の家計簿データを削除することができます。
        RESPONSE
      end

      it "return expense_input_first_message" do
        expect(result).to eq(response_message.chomp)
      end
    end

    # 収入データ入力
    context "when input income record" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:INCOME_INPUT] }
      let(:response_message) do
        <<~RESPONSE
          トークモード: 収入入力
          ---------------------------------
          収入データを入力する場合は、

          費目
          金額（半角数字）
          備考（任意）
          日付 (任意 例: 2023-08-08)

          の形で入力してください。
          金額部分には「円」などの表記は不要です。

          誤って入力してしまった場合
          「とりけし」と入力することで、直前の家計簿データを削除することができます。
        RESPONSE
      end

      it "return income_input_first_message" do
        expect(result).to eq(response_message.chomp)
      end
    end

    # 家計簿データ確認
    context "when show expense records" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:SHOW] }
      let(:response_message) do
        <<~RESPONSE
          トークモード: 確認
          ---------------------------------
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

          ※「今月」のみ入力すると、個人とグループ（所属している場合）の費目別合計が表示されます。
        RESPONSE
      end

      it "return show_first_message" do
        expect(result).to eq(response_message.chomp)
      end
    end

    # グループ作成・参加
    context "when create or participate in group" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:GROUP] }

      context "when user does not belong to any group" do
        let(:response_message) do
          <<~RESPONSE
            トークモード: グループ
            --------------------------------------
            グループを新しく作成する場合は「作成」と入力してください。
            グループに参加する場合は「参加」と入力してください。
          RESPONSE
        end

        it "transitions to group_mode and returns group_mode_message" do
          expect(result).to eq(response_message.chomp)
          expect(user.reload.talk_mode).to eq("group_mode")
        end
      end

      context "when user already belongs to a group" do
        let!(:group) { create(:group, name: "既存グループ") }
        let(:user) { create(:user, line_id:, group:) }
        let(:response_message) do
          <<~RESPONSE
            トークモード: グループ脱退確認
            --------------------------------------
            グループ「既存グループ」から脱退しますか？

            脱退する場合は「はい」、キャンセルする場合は「いいえ」と入力してください。
          RESPONSE
        end

        it "transitions to group_leaving_confirmation_mode and returns confirmation message" do
          expect(result).to eq(response_message.chomp)
          expect(user.reload.talk_mode).to eq("group_leaving_confirmation_mode")
        end
      end
    end

    # ヘルプ
    context "when show help message" do
      let(:message) { MessageHandler::CoreHandler::BUILT_IN_MESSAGE[:HELP] }
      let(:response_message) do
        <<~RESPONSE
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
        RESPONSE
      end

      it "return help_message" do
        expect(result).to eq(response_message.chomp)
      end
    end
  end
end
