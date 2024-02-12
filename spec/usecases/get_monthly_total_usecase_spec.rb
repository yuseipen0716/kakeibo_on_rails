require 'rails_helper'

RSpec.describe GetMonthlyTotalUsecase, type: :usecase do
  describe 'perform' do
    let(:usecase) { described_class.perform(user:, period:, category: category_name) }
    let(:user) { create(:user) }
    let(:period) { Time.zone.now.beginning_of_month..Time.zone.now.end_of_day }

    before do
      create(
        :expense_record,
        amount: 1500,
        transaction_date: Time.zone.now,
        user:,
        category: create(:category, name: '食費')
      )
    end

    context 'categoryが未指定の場合' do
      let(:category_name) { nil }

      it '今月の合計金額が返される' do
        expect(usecase).to eq('1500円ナリ')
      end
    end

    context '論理削除されているレコードが存在する場合' do
      let(:category_name) { nil }

      before do
        create(
          :expense_record,
          amount: 1000,
          transaction_date: Time.zone.now,
          user:,
          category: create(:category, name: '電気代'),
          is_disabled: true # 論理削除済み
        )
      end

      it '論理削除済みの家計簿データの分は合計に加算されない' do
        # このcontextで追加したexpense_recordの1000円分は加算されないので、
        # 合計は1500円になる。
        expect(usecase).to eq('1500円ナリ')
      end
    end

    context 'categoryが指定されている場合' do
      context '指定したcategory（食費）の家計簿データが存在する場合' do
        let(:category_name) { create(:category, name: '食費').name }

        it '今月の食費の合計金額が返される' do
          expect(usecase).to eq('1500円ナリ')
        end
      end

      context '指定したcategory（医療費）の家計簿データが存在しない場合' do
        let(:category_name) { create(:category, name: '医療費').name }

        it '0円が返される' do
          expect(usecase).to eq('0円ナリ')
        end
      end

      context '論理削除されているレコードが存在する場合' do
        let(:category_name) { create(:category, name: '食費').name }

        before do
          create(
            :expense_record,
            amount: 1000,
            transaction_date: Time.zone.now,
            user:,
            category: create(:category, name: '食費'),
            is_disabled: true
          )
        end

        it '今月の食費の合計金額が返される（論理削除済みの家計簿データ分は加算されない）' do
          expect(usecase).to eq('1500円ナリ')
        end
      end
    end
  end
end
