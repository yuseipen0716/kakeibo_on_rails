require 'rails_helper'

RSpec.describe CreateExpenseRecordUsecase, type: :usecase do
  describe 'perform' do
    let(:usecase) { described_class.perform(expense_record_attrs:, expense_type:, user:) }
    let(:user) { create(:user) }

    context 'when expense type is :expense' do
      let(:expense_type) { :expense }
      let(:expense_record_attrs) do
        {
          category: '食費',
          amount: 500,
          memorandum: 'memorandum',
          transaction_date: Time.zone.today.to_date.to_s
        }
      end
      let(:return_message) do
        <<~MESSAGE
          支出データの登録に成功しました💡

          費目: 食費
          金額: 500
          備考: memorandum
          日付: #{Time.zone.today.to_date}
        MESSAGE
      end

      it 'succeeds in creating a new expense record' do
        expect { usecase }.to change(ExpenseRecord, :count).from(0).to(1)
      end

      it '登録した支出データが記載されたメッセージが返される' do
        expect(usecase).to eq(return_message.chomp)
      end
    end

    context 'when expense type is :income' do
      let(:expense_type) { :income }
      let(:expense_record_attrs) do
        {
          category: '給与',
          amount: 200_000,
          memorandum: 'memorandum',
          transaction_date: Time.zone.today.to_date.to_s
        }
      end
      let(:return_message) do
        <<~MESSAGE
          収入データの登録に成功しました💡

          費目: 給与
          金額: 200000
          備考: memorandum
          日付: #{Time.zone.today.to_date}
        MESSAGE
      end

      it 'succeeds in creating a new income record' do
        expect { usecase }.to change(ExpenseRecord, :count).from(0).to(1)
      end

      it '登録した収入データが記載されたメッセージが返される' do
        expect(usecase).to eq(return_message.chomp)
      end
    end

    context 'when optional item in expense_record_attrs is empty' do
      let(:expense_type) { :expense }
      let(:expense_record_attrs) do
        {
          category: '食費',
          amount: 500,
          transaction_date: Time.zone.today.to_date.to_s
        }
      end

      it 'succeeds in creating a new expense record' do
        expect { usecase }.to change(ExpenseRecord, :count).from(0).to(1)
      end
    end
  end
end
