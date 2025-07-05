module MessageHandler
  class GroupMessageHandler
    MESSAGE_TYPE = :group

    CREATE_COMMAND = "作成".freeze
    JOIN_COMMAND = "参加".freeze

    class << self
      def perform(user, message)
        case user.talk_mode.to_sym
        when :group_mode
          handle_group_mode(user, message)
        when :group_creating_mode
          handle_group_creating_mode(user, message)
        when :group_joining_mode
          handle_group_joining_mode(user, message)
        else
          "不明なグループモード"
        end
      end

      private

      def handle_group_mode(user, message)
        case message
        when CREATE_COMMAND
          user.update(talk_mode: :group_creating_mode)
          group_creating_first_message
        when JOIN_COMMAND
          user.update(talk_mode: :group_joining_mode)
          group_joining_first_message
        else
          group_mode_message
        end
      end

      def handle_group_creating_mode(user, message)
        group_name = message.strip

        # バリデーション
        validation_error = validate_group_creation(user, group_name)
        return validation_error if validation_error

        # グループ作成処理
        create_group_for_user(user, group_name)
      end

      def handle_group_joining_mode(user, message)
        group_name = message.strip

        # バリデーション
        validation_error = validate_group_joining(user, group_name)
        return validation_error if validation_error

        # グループ参加処理
        join_existing_group(user, group_name)
      end

      def group_mode_message
        message = "トークモード: #{User.human_attribute_name("talk_mode.group_mode")}\n"
        message << "--------------------------------------\n"
        message << "グループを新しく作成する場合は「作成」と入力してください。\nグループに参加する場合は「参加」と入力してください。\n"

        message.chomp
      end

      def group_creating_first_message
        message = "トークモード: #{User.human_attribute_name("talk_mode.group_creating_mode")}\n"
        message << "--------------------------------------\n"
        message << "グループを作成します。どのようなグループ名にしますか？\n"
        message << "（10文字以内で入力してください）"

        message.chomp
      end

      def group_joining_first_message
        message = "トークモード: #{User.human_attribute_name("talk_mode.group_joining_mode")}\n"
        message << "--------------------------------------\n"
        message << "参加したいグループ名を入力してください"

        message.chomp
      end

      def validate_group_creation(user, group_name)
        return "グループ名を入力してください。" if group_name.blank?
        return "グループ名は10文字以内で入力してください。" if group_name.length > 10
        return "そのグループ名は既に使用されています。別のグループ名で作成してください。" if Group.exists?(name: group_name)

        if user.group.present?
          user.update(talk_mode: :default_mode)
          return "既にグループに参加しています。"
        end

        nil
      end

      def create_group_for_user(user, group_name)
        ActiveRecord::Base.transaction do
          group = Group.create!(name: group_name)
          user.update!(group: group, talk_mode: :default_mode)
          group_creation_success_message(group)
        end
      rescue ActiveRecord::RecordInvalid => e
        "グループの作成に失敗しました。#{e.message}"
      end

      def group_creation_success_message(group)
        message = "グループを作成しました。\n\n"
        message << "グループ名: #{group.name}\n"
        message << "参加メンバー: #{group.users.count}人"

        # TODO: 今後、家計簿データの確認モードで同じグループの家計簿データの合計を出す機能などを実装予定
        message
      end

      def validate_group_joining(user, group_name)
        return "グループ名を入力してください。" if group_name.blank?

        target_group = Group.find_by(name: group_name)
        return "指定されたグループは存在しません。" unless target_group

        if user.group.present?
          user.update(talk_mode: :default_mode)
          return "既にそのグループに参加しています。" if user.group == target_group

          return "既にグループに参加しています。"
        end

        nil
      end

      def join_existing_group(user, group_name)
        target_group = Group.find_by(name: group_name)

        ActiveRecord::Base.transaction do
          user.update!(group: target_group, talk_mode: :default_mode)
          group_joining_success_message(target_group)
        end
      rescue ActiveRecord::RecordInvalid => e
        "グループへの参加に失敗しました。#{e.message}"
      end

      def group_joining_success_message(group)
        message = "グループ: #{group.name} に参加しました。\n\n"
        message << "グループ名: #{group.name}\n"
        message << "参加メンバー: #{group.users.count}人"

        # TODO: 今後、家計簿データの確認モードで同じグループの家計簿データの合計を出す機能などを実装予定
        message
      end
    end
  end
end
