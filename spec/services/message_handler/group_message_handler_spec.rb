require "rails_helper"

RSpec.describe MessageHandler::GroupMessageHandler, type: :service do
  describe ".perform" do
    let(:user) { create(:user, talk_mode: :group_mode) }

    context "when user is in group_mode" do
      let(:user) { create(:user, talk_mode: :group_mode) }

      context "with CREATE_COMMAND" do
        it "transitions to group_creating_mode" do
          expect do
            MessageHandler::GroupMessageHandler.perform(user, "作成")
          end.to change { user.reload.talk_mode }.from("group_mode").to("group_creating_mode")
        end

        it "returns group creation first message" do
          result = MessageHandler::GroupMessageHandler.perform(user, "作成")
          expect(result).to include("グループを作成します。どのようなグループ名にしますか？")
          expect(result).to include("（10文字以内で入力してください）")
        end
      end

      context "with JOIN_COMMAND" do
        it "transitions to group_joining_mode" do
          expect do
            MessageHandler::GroupMessageHandler.perform(user, "参加")
          end.to change { user.reload.talk_mode }.from("group_mode").to("group_joining_mode")
        end

        it "returns group joining first message" do
          result = MessageHandler::GroupMessageHandler.perform(user, "参加")
          expect(result).to include("参加したいグループ名を入力してください")
        end
      end

      context "with unknown command" do
        it "returns original group mode message" do
          result = MessageHandler::GroupMessageHandler.perform(user, "不明なコマンド")
          expect(result).to include("グループを新しく作成する場合は「作成」と入力してください")
          expect(result).to include("グループに参加する場合は「参加」と入力してください")
        end

        it "does not change talk_mode" do
          expect do
            MessageHandler::GroupMessageHandler.perform(user, "不明なコマンド")
          end.not_to(change { user.reload.talk_mode })
        end
      end
    end

    context "when user is in group_creating_mode" do
      let(:user) { create(:user, talk_mode: :group_creating_mode) }

      it "returns placeholder message" do
        result = MessageHandler::GroupMessageHandler.perform(user, "テストグループ")
        expect(result).to eq("グループ作成処理（未実装）")
      end
    end

    context "when user is in group_joining_mode" do
      let(:user) { create(:user, talk_mode: :group_joining_mode) }

      it "returns placeholder message" do
        result = MessageHandler::GroupMessageHandler.perform(user, "テストグループ")
        expect(result).to eq("グループ参加処理（未実装）")
      end
    end

    context "when user is in unknown group mode" do
      let(:user) { create(:user, talk_mode: :default_mode) }

      it "returns unknown mode message" do
        result = MessageHandler::GroupMessageHandler.perform(user, "メッセージ")
        expect(result).to eq("不明なグループモード")
      end
    end
  end
end
