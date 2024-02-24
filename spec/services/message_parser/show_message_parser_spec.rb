require 'rails_helper'

RSpec.describe MessageParser::ShowMessageParser do
  describe 'perform' do
    let(:result) { described_class.perform(message:, user:) }
    let(:user) { create(:user, talk_mode: :show_mode) }

    before do
      # 保存済みの家計簿データを用意しておく
      create(
        :expense_record,
        amount: 1500,
        transaction_date: Time.zone.now,
        user:,
        category: create(:category, name: '食費')
      )

      create(
        :expense_record,
        amount: 3000,
        transaction_date: Time.zone.now,
        user:,
        category: create(:category, name: '交通費')
      )

      create(
        :expense_record,
        amount: 2000,
        transaction_date: 1.month.ago,
        user:,
        category: create(:category, name: '食費')
      )

      create(
        :expense_record,
        amount: 3000,
        transaction_date: Time.zone.parse('2023-11-01'),
        user:,
        category: create(:category, name: '交際費')
      )
    end

    context 'when message is valid' do
      context 'when specify yyyy-mm' do
        let(:message) { '2023-11' }

        it "returns 2023/11's total" do
          expect(result).to eq("2023年11月の費目別合計\n\n交際費: 3000円")
        end
      end

      context "when show last month's total" do
        context "message contains '合計'" do
          let(:message) { "先月\n合計" }

          it "returns last month's total" do
            expect(result).to eq("#{1.month.ago.strftime('%Y年%m月')}の合計\n\n2000円ナリ")
          end
        end

        context "message does not contain '合計'" do
          let(:message) { '先月' }

          it "returns last month's total" do
            expect(result).to eq("#{1.month.ago.strftime('%Y年%m月')}の費目別合計\n\n食費: 2000円")
          end
        end
      end

      context 'when show the total of the specified category for the last month' do
        context 'when the total of the specified category is 0' do
          before { create(:category, name: '医療費') }
          let(:message) { "先月\n医療費" }

          it 'returns 0 yen' do
            expect(result).to eq("#{1.month.ago.strftime('%Y年%m月')}の医療費\n\n0円ナリ")
          end
        end

        context 'when the total of the specified category is not 0' do
          let(:message) { "先月\n食費" }

          it 'returns the total of food for the last month' do
            expect(result).to eq("#{1.month.ago.strftime('%Y年%m月')}の食費\n\n2000円ナリ")
          end
        end
      end

      context "when show this month's total" do
        context "message contains '合計'" do
          let(:message) { "今月\n合計" }

          it "returns this month's total" do
            expect(result).to eq("#{Time.zone.now.strftime('%Y年%m月')}の合計\n\n4500円ナリ")
          end
        end

        context "message does not contain '合計'" do
          let(:message) { '今月' }

          it "returns this month's total" do
            expect(result).to eq("#{Time.zone.now.strftime('%Y年%m月')}の費目別合計\n\n交通費: 3000円\n食費: 1500円")
          end
        end
      end

      context 'when show the total of the specified category for the this month' do
        context 'when the total of the specified category is 0' do
          before { create(:category, name: '医療費') }
          let(:message) { "今月\n医療費" }

          it 'returns 0 yen' do
            expect(result).to eq("#{Time.zone.now.strftime('%Y年%m月')}の医療費\n\n0円ナリ")
          end
        end

        context 'when the total of the specified category is not 0' do
          let(:message) { "今月\n食費" }

          it 'returns the total of food for the this month' do
            expect(result).to eq("#{Time.zone.now.strftime('%Y年%m月')}の食費\n\n1500円ナリ")
          end
        end
      end
    end

    context 'when message is invalid' do
      context 'Period designation is invalid' do
        context "Period designation is neither '先月' or '今月'" do
          let(:message) { '先々月' }

          it 'returns error message' do
            expect(result).to include('期間（月）の指定方法が正しくありません。')
          end
        end

        context 'Period designation is not yyyy-mm' do
          let(:message) { '2023-11-01' }

          it 'returns error message' do
            expect(result).to include('期間（月）の指定方法が正しくありません。')
          end
        end
      end

      context 'Category is not found' do
        let(:message) { "今月\n医療費" }

        it 'returns error message' do
          expect(result).to include('入力いただいた費目が見つかりませんでした。')
        end
      end
    end
  end
end
