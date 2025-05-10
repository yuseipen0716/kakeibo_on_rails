require "rails_helper"

RSpec.describe MessageParser::InputMessageParser do
  describe "perform" do
    let(:result) { described_class.perform(message:, user:) }
    let(:user) { create(:user, talk_mode:) }

    context "when user.talk_mode is input_mode" do
      let(:talk_mode) { :input_mode }

      context "when message is `支出`" do
        let(:message) { "支出" }
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

        it "returns expense_input description" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when message is `収入`" do
        let(:message) { "収入" }
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

        it "returns income_input description" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when message is not `支出` or `収入`" do
        let(:message) { "あいう" }
        let(:response_message) { "メッセージの形式が正しくありません。\nもう一度最初から操作を行ってください。" }

        it "returns error message" do
          expect(result).to eq(response_message)
        end

        it "is changed talk_mode into default_mode" do
          result
          expect(user.talk_mode.to_sym).to eq(:default_mode)
        end
      end
    end

    context "when user.talk_mode is expense_input_mode" do
      let(:talk_mode) { :expense_input_mode }

      context "when expense_input message is valid" do
        let(:message) { "食費\n1000\nラーメン\n2023-12-30" }
        let(:response_message) do
          <<~RESPONSE
            支出データの登録に成功しました💡

            費目: 食費
            金額: 1000
            備考: ラーメン
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and memorandum is empty" do
        let(:message) { "食費\n1000\n2023-12-30" }
        let(:response_message) do
          <<~RESPONSE
            支出データの登録に成功しました💡

            費目: 食費
            金額: 1000
            備考:#{" "}
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and transaction_date is empty" do
        let(:message) { "食費\n1000\nラーメン" }
        let(:response_message) do
          <<~RESPONSE
            支出データの登録に成功しました💡

            費目: 食費
            金額: 1000
            備考: ラーメン
            日付: #{Time.zone.today.to_date}
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and date does not have `-`" do
        let(:message) { "食費\n1000\nラーメン\n20231230" }
        let(:response_message) do
          <<~RESPONSE
            支出データの登録に成功しました💡

            費目: 食費
            金額: 1000
            備考: ラーメン
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and date splitted `/`" do
        let(:message) { "食費\n1000\nラーメン\n2023/12/30" }
        let(:response_message) do
          <<~RESPONSE
            支出データの登録に成功しました💡

            費目: 食費
            金額: 1000
            備考: ラーメン
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "入力したデータを取り消す場合" do
        let(:message) { "とりけし" }
        let(:response_message) do
          <<~MESSAGE
            以下の家計簿データを取り消しました💡

            費目: 食費
            金額: 1500
            備考: memorandum
            日付: #{Time.zone.now.to_date}
          MESSAGE
        end

        before do
          # 論理削除されていない支出データを準備しておく
          create(
            :expense_record,
            user:,
            expense_type: :expense,
            amount: 1500,
            category: create(:category, name: "食費"),
            transaction_date: Time.zone.today,
            memorandum: "memorandum",
            is_disabled: false
          )
        end

        it "最新の家計簿データが論理削除される" do
          result
          expect(user.expense_records.last.is_disabled).to be_truthy
        end

        it "とりけし成功のメッセージが返却される" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "入力テンプレートをリクエストする場合" do
        let(:message) { "テンプレ" }
        let(:response_message) do
          <<~MESSAGE
            食費
            1000
            ラーメン
            #{Time.zone.today.strftime("%Y-%m-%d")}
          MESSAGE
        end

        it "入力テンプレートが返却される" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "費目リストを確認する場合" do
        let(:message) { "費目" }

        context "when expense record is empty" do
          let(:response_message) { "表示できる費目が存在しません。" }

          it "returns empty message" do
            expect(result).to eq(response_message)
          end
        end

        context "when expense record exists" do
          before do
            create(
              :expense_record,
              expense_type: :expense,
              category: create(:category, name: "食費"),
              user:
            )
            create(
              :expense_record,
              expense_type: :expense,
              category: create(:category, name: "書籍"),
              user:
            )
          end

          let(:response_message) do
            <<~MESSAGE
              これまでに使用したことのある費目

              食費
              書籍
            MESSAGE
          end

          it "これまでに使用したことのある費目名が返却される" do
            expect(result).to eq(response_message.chomp)
          end
        end
      end

      context "when expense_input message is invalid" do
        context "when category is empty" do
          let(:message) { "" }

          it "fails to create a expense record" do
            expect(result).to include("費目の入力は必須です。")
          end
        end

        context "when amount is empty" do
          let(:message) { "食費" }

          it "fails to create a expense record" do
            expect(result).to include("金額の入力は必須です。")
          end
        end

        context "when category has over 10 characters" do
          let(:message) { "12345678901" }

          it "fails to create a expense record" do
            expect(result).to include("費目は10文字以内で設定してください。")
          end
        end

        context "when amount is composed by full-width characters" do
          let(:message) { "食費\n１０００" }

          it "fails to create a expense record" do
            expect(result).to include("金額は半角数字で入力してください。円などの単位も不要です。")
          end
        end

        context "when amount includes unit" do
          let(:message) { "食費\n1000円" }

          it "fails to create a expense record" do
            expect(result).to include("金額は半角数字で入力してください。円などの単位も不要です。")
          end
        end

        context "when transaction date is invalid" do
          let(:message) { "食費\n1000\nラーメン\nnot_date" }

          it "fails to create a expense record" do
            expect(result).to include("入力された日付の値が不正です。")
          end
        end
      end
    end

    context "when user.talk_mode is income_input_mode" do
      let(:talk_mode) { :income_input_mode }

      context "when expense_input message is valid" do
        let(:message) { "給与\n200000\n12月給与\n2023-12-30" }
        let(:response_message) do
          <<~RESPONSE
            収入データの登録に成功しました💡

            費目: 給与
            金額: 200000
            備考: 12月給与
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and memorandum is empty" do
        let(:message) { "給与\n200000\n2023-12-30" }
        let(:response_message) do
          <<~RESPONSE
            収入データの登録に成功しました💡

            費目: 給与
            金額: 200000
            備考:#{" "}
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and transaction_date is empty" do
        let(:message) { "給与\n200000\n12月給与" }
        let(:response_message) do
          <<~RESPONSE
            収入データの登録に成功しました💡

            費目: 給与
            金額: 200000
            備考: 12月給与
            日付: #{Time.zone.today.to_date}
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and date does not have `-`" do
        let(:message) { "給与\n200000\n12月給与\n20231230" }
        let(:response_message) do
          <<~RESPONSE
            収入データの登録に成功しました💡

            費目: 給与
            金額: 200000
            備考: 12月給与
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "when expense_input message is valid and date splitted `/`" do
        let(:message) { "給与\n200000\n12月給与\n2023/12/30" }
        let(:response_message) do
          <<~RESPONSE
            収入データの登録に成功しました💡

            費目: 給与
            金額: 200000
            備考: 12月給与
            日付: 2023-12-30
          RESPONSE
        end

        it "succeeds in creating expense_record" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "入力したデータを取り消す場合" do
        let(:message) { "とりけし" }
        let(:response_message) do
          <<~MESSAGE
            以下の家計簿データを取り消しました💡

            費目: 給与
            金額: 150000
            備考: memorandum
            日付: #{Time.zone.now.to_date}
          MESSAGE
        end

        before do
          # 論理削除されていない収入データを準備しておく
          create(
            :expense_record,
            user:,
            expense_type: :income,
            amount: 150_000,
            category: create(:category, name: "給与"),
            transaction_date: Time.zone.today,
            memorandum: "memorandum",
            is_disabled: false
          )
        end

        it "最新の家計簿データが論理削除される" do
          result
          expect(user.expense_records.last.is_disabled).to be_truthy
        end

        it "とりけし成功のメッセージが返却される" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "入力テンプレートをリクエストする場合" do
        let(:message) { "テンプレ" }
        let(:response_message) do
          <<~MESSAGE
            食費
            1000
            ラーメン
            #{Time.zone.today.strftime("%Y-%m-%d")}
          MESSAGE
        end

        it "入力テンプレートが返却される" do
          expect(result).to eq(response_message.chomp)
        end
      end

      context "費目リストを確認する場合" do
        let(:message) { "費目" }

        context "when expense record is empty" do
          let(:response_message) { "表示できる費目が存在しません。" }

          it "returns empty message" do
            expect(result).to eq(response_message)
          end
        end

        context "when expense record exists" do
          before do
            create(
              :expense_record,
              expense_type: :income,
              category: create(:category, name: "給与"),
              user:
            )
            create(
              :expense_record,
              expense_type: :income,
              category: create(:category, name: "贈与"),
              user:
            )
          end

          let(:response_message) do
            <<~MESSAGE
              これまでに使用したことのある費目

              給与
              贈与
            MESSAGE
          end

          it "これまでに使用したことのある費目名が返却される" do
            expect(result).to eq(response_message.chomp)
          end
        end
      end

      context "when expense_input message is invalid" do
        context "when category is empty" do
          let(:message) { "" }

          it "fails to create a expense record" do
            expect(result).to include("費目の入力は必須です。")
          end
        end

        context "when amount is empty" do
          let(:message) { "給与" }

          it "fails to create a expense record" do
            expect(result).to include("金額の入力は必須です。")
          end
        end

        context "when category has over 10 characters" do
          let(:message) { "12345678901" }

          it "fails to create a expense record" do
            expect(result).to include("費目は10文字以内で設定してください。")
          end
        end

        context "when amount is composed by full-width characters" do
          let(:message) { "給与\n２０００００" }

          it "fails to create a expense record" do
            expect(result).to include("金額は半角数字で入力してください。円などの単位も不要です。")
          end
        end

        context "when amount includes unit" do
          let(:message) { "給与\n200000円" }

          it "fails to create a expense record" do
            expect(result).to include("金額は半角数字で入力してください。円などの単位も不要です。")
          end
        end

        context "when transaction date is invalid" do
          let(:message) { "給与\n200000\n12月給与\nnot_date" }

          it "fails to create a expense record" do
            expect(result).to include("入力された日付の値が不正です。")
          end
        end
      end
    end
  end
end
