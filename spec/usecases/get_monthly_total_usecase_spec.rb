require "rails_helper"

RSpec.describe GetMonthlyTotalUsecase, type: :usecase do
  describe "perform" do
    let(:usecase) { described_class.new(user:, period:, category: category_name).perform }
    let(:user) { create(:user) }
    let(:period) { Time.zone.now.beginning_of_month..Time.zone.now.end_of_day }

    before do
      create(
        :expense_record,
        amount: 1500,
        transaction_date: Time.zone.now,
        user:,
        category: create(:category, name: "食費")
      )
    end

    context "categoryが未指定の場合" do
      let(:category_name) { nil }

      before do
        create(
          :expense_record,
          amount: 3800,
          transaction_date: Time.zone.now,
          user:,
          category: create(:category, name: "医療費")
        )
      end

      it "今月の費目ごとの合計金額が個人とグループ（所属していない場合は個人のみ）で返される" do
        expected_message = "#{Time.zone.now.strftime("%Y年%m月")}の費目別合計\n\n<個人>\n医療費: 3800円\n食費: 1500円"
        expect(usecase).to eq(expected_message)
      end
    end

    context "categoryが「合計」の場合" do
      let(:category_name) { "合計" }

      it "今月の合計金額が返される" do
        expect(usecase).to eq("#{Time.zone.now.strftime("%Y年%m月")}の合計\n\n1500円ナリ")
      end
    end

    context "論理削除されているレコードが存在する場合" do
      let(:category_name) { "合計" }

      before do
        create(
          :expense_record,
          amount: 1000,
          transaction_date: Time.zone.now,
          user:,
          category: create(:category, name: "電気代"),
          is_disabled: true # 論理削除済み
        )
      end

      it "論理削除済みの家計簿データの分は合計に加算されない" do
        # このcontextで追加したexpense_recordの1000円分は加算されないので、
        # 合計は1500円になる。
        expect(usecase).to eq("#{Time.zone.now.strftime("%Y年%m月")}の合計\n\n1500円ナリ")
      end
    end

    context "categoryが指定されている場合" do
      context "指定したcategory（食費）の家計簿データが存在する場合" do
        let(:category_name) { create(:category, name: "食費").name }

        it "今月の食費の合計金額が返される" do
          expect(usecase).to eq("#{Time.zone.now.strftime("%Y年%m月")}の食費\n\n1500円ナリ")
        end
      end

      context "指定したcategory（医療費）の家計簿データが存在しない場合" do
        let(:category_name) { create(:category, name: "医療費").name }

        it "0円が返される" do
          expect(usecase).to eq("#{Time.zone.now.strftime("%Y年%m月")}の医療費\n\n0円ナリ")
        end
      end

      context "論理削除されているレコードが存在する場合" do
        let(:category_name) { create(:category, name: "食費").name }

        before do
          create(
            :expense_record,
            amount: 1000,
            transaction_date: Time.zone.now,
            user:,
            category: create(:category, name: "食費"),
            is_disabled: true
          )
        end

        it "今月の食費の合計金額が返される（論理削除済みの家計簿データ分は加算されない）" do
          expect(usecase).to eq("#{Time.zone.now.strftime("%Y年%m月")}の食費\n\n1500円ナリ")
        end
      end
    end

    context "グループ機能のテスト" do
      let(:category_name) { nil }
      let(:group) { create(:group) }
      let(:group_member) { create(:user, group:) }

      before do
        user.update!(group:)

        # グループメンバーの支出データを作成
        create(
          :expense_record,
          amount: 2000,
          transaction_date: Time.zone.now,
          user: group_member,
          category: create(:category, name: "食費")
        )
        create(
          :expense_record,
          amount: 1000,
          transaction_date: Time.zone.now,
          user: group_member,
          category: create(:category, name: "交通費")
        )
      end

      it "個人とグループの費目別合計が返される" do
        expected_message = "#{Time.zone.now.strftime("%Y年%m月")}の費目別合計\n\n<個人>\n食費: 1500円\n\n<グループ>\n交通費: 1000円\n食費: 3500円"
        expect(usecase).to eq(expected_message)
      end
    end

    context "グループに所属しているが個人データがない場合" do
      let(:category_name) { nil }
      let(:group) { create(:group) }
      let(:user_without_data) { create(:user, group:) }
      let(:usecase) { described_class.new(user: user_without_data, period:, category: category_name).perform }

      before do
        # 同じグループに所属するメンバーを作成してデータを追加
        user.update!(group:)
        create(
          :expense_record,
          amount: 2000,
          transaction_date: Time.zone.now,
          user:,
          category: create(:category, name: "食費")
        )
      end

      it "個人はデータなし、グループの合計が表示される" do
        expected_message = "#{Time.zone.now.strftime("%Y年%m月")}の費目別合計\n\n<個人>\nデータなし\n\n<グループ>\n食費: 3500円"
        expect(usecase).to eq(expected_message)
      end
    end
  end
end
