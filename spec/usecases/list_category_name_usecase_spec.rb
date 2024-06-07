require 'rails_helper'

RSpec.describe ListCategoryNameUsecase, type: :usecase do
  describe '#perform' do
    let(:usecase) { described_class.new(user).perform }
    let(:user) { create(:user, talk_mode: current_talk_mode) }

    context 'when talk_mode is expense' do
      let(:current_talk_mode) { :expense_input_mode }

      context 'when record is empty' do
        it 'returns []' do
          expect(usecase).to eq([])
        end
      end

      context 'when expense_record exists' do
        before do
          create(
            :expense_record,
            expense_type: :expense,
            category: create(:category, name: '食費'),
            user:
          )
        end

        it 'returns category name' do
          expect(usecase).to eq(['食費'])
        end
      end
    end

    context 'when talk_mode is expense' do
      let(:current_talk_mode) { :income_input_mode }

      context 'when record is empty' do
        it 'returns []' do
          expect(usecase).to eq([])
        end
      end

      context 'when income_record exists' do
        before do
          create(
            :expense_record,
            expense_type: :income,
            category: create(:category, name: '給与'),
            user:
          )
        end

        it 'returns category name' do
          expect(usecase).to eq(['給与'])
        end
      end
    end
  end
end
