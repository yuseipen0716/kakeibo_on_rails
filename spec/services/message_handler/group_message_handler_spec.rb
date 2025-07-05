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

      context "with valid group name" do
        it "creates group and associates user" do
          expect do
            MessageHandler::GroupMessageHandler.perform(user, "新しいグループ")
          end.to change(Group, :count).by(1)
        end

        it "updates user's group and talk_mode" do
          MessageHandler::GroupMessageHandler.perform(user, "新しいグループ")
          user.reload
          expect(user.group.name).to eq("新しいグループ")
          expect(user.talk_mode).to eq("default_mode")
        end

        it "returns success message" do
          result = MessageHandler::GroupMessageHandler.perform(user, "新しいグループ")
          expect(result).to include("グループを作成しました。")
          expect(result).to include("グループ名: 新しいグループ")
          expect(result).to include("参加メンバー: 1人")
        end

        it "handles group name with special characters" do
          result = MessageHandler::GroupMessageHandler.perform(user, "家族😊💰")
          expect(result).to include("グループを作成しました。")
          expect(result).to include("グループ名: 家族😊💰")
        end

        it "handles exactly 10 character group name" do
          result = MessageHandler::GroupMessageHandler.perform(user, "1234567890")
          expect(result).to include("グループを作成しました。")
          expect(result).to include("グループ名: 1234567890")
        end
      end

      context "with validation errors" do
        it "returns error message for blank group name" do
          result = MessageHandler::GroupMessageHandler.perform(user, "")
          expect(result).to eq("グループ名を入力してください。")
        end

        it "returns error message for whitespace only group name" do
          result = MessageHandler::GroupMessageHandler.perform(user, "   ")
          expect(result).to eq("グループ名を入力してください。")
        end

        it "returns error message for group name longer than 10 characters" do
          result = MessageHandler::GroupMessageHandler.perform(user, "12345678901")
          expect(result).to eq("グループ名は10文字以内で入力してください。")
        end

        it "returns error message for multi-byte characters exceeding 10 characters" do
          result = MessageHandler::GroupMessageHandler.perform(user, "あいうえおかきくけこさ") # 11文字
          expect(result).to eq("グループ名は10文字以内で入力してください。")
        end

        it "returns error message for duplicate group name" do
          create(:group, name: "既存グループ")
          result = MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          expect(result).to eq("そのグループ名は既に使用されています。別のグループ名で作成してください。")
        end

        it "returns error message and changes talk_mode when user already belongs to a group" do
          existing_group = create(:group, name: "既存グループ")
          user.update(group: existing_group)

          result = MessageHandler::GroupMessageHandler.perform(user, "新しいグループ")
          expect(result).to eq("既にグループに参加しています。")
          expect(user.reload.talk_mode).to eq("default_mode")
        end
      end

      context "with database errors" do
        it "handles ActiveRecord errors gracefully" do
          allow(Group).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Group.new))
          result = MessageHandler::GroupMessageHandler.perform(user, "テストグループ")
          expect(result).to include("グループの作成に失敗しました。")
        end
      end
    end

    context "when user is in group_joining_mode" do
      let(:user) { create(:user, talk_mode: :group_joining_mode) }

      context "with valid group name" do
        let!(:existing_group) { create(:group, name: "既存グループ") }

        it "joins existing group and associates user" do
          expect do
            MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          end.to change { user.reload.group }.from(nil).to(existing_group)
        end

        it "updates user's talk_mode to default_mode" do
          MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          expect(user.reload.talk_mode).to eq("default_mode")
        end

        it "returns success message" do
          result = MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          expect(result).to include("グループ: 既存グループ に参加しました。")
          expect(result).to include("グループ名: 既存グループ")
          expect(result).to include("参加メンバー: 1人")
        end

        it "increments group member count when multiple users join" do
          another_user = create(:user)
          existing_group.users << another_user

          result = MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          expect(result).to include("参加メンバー: 2人")
        end
      end

      context "with validation errors" do
        it "returns error message for blank group name" do
          result = MessageHandler::GroupMessageHandler.perform(user, "")
          expect(result).to eq("グループ名を入力してください。")
        end

        it "returns error message for whitespace only group name" do
          result = MessageHandler::GroupMessageHandler.perform(user, "   ")
          expect(result).to eq("グループ名を入力してください。")
        end

        it "returns error message for non-existent group" do
          result = MessageHandler::GroupMessageHandler.perform(user, "存在しないグループ")
          expect(result).to eq("指定されたグループは存在しません。")
        end

        it "returns error message and changes talk_mode when user already belongs to a group" do
          existing_group = create(:group, name: "既存グループ")
          create(:group, name: "別のグループ")
          user.update(group: existing_group)

          result = MessageHandler::GroupMessageHandler.perform(user, "別のグループ")
          expect(result).to eq("既にグループに参加しています。")
          expect(user.reload.talk_mode).to eq("default_mode")
        end

        it "returns error message and changes talk_mode when user already belongs to the same group" do
          existing_group = create(:group, name: "同じグループ")
          user.update(group: existing_group)

          result = MessageHandler::GroupMessageHandler.perform(user, "同じグループ")
          expect(result).to eq("既にそのグループに参加しています。")
          expect(user.reload.talk_mode).to eq("default_mode")
        end
      end

      context "with database errors" do
        let!(:existing_group) { create(:group, name: "既存グループ") }

        it "handles ActiveRecord errors gracefully" do
          allow(user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user))
          result = MessageHandler::GroupMessageHandler.perform(user, "既存グループ")
          expect(result).to include("グループへの参加に失敗しました。")
        end
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
