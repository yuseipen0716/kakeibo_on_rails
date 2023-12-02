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

      it 'succeeds in creating a new expense record' do
        expect { usecase }.to change(ExpenseRecord, :count).from(0).to(1)
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

      it 'succeeds in creating a new income record' do
        expect { usecase }.to change(ExpenseRecord, :count).from(0).to(1)
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
