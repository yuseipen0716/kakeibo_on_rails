# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validation of name' do
    let(:category) { Category.new(name:) }
    context 'name length within 10' do
      let(:name) { '1234567890' }

      it 'is valid with a name' do
        expect(category).to be_valid
      end
    end

    context 'name length is over 10' do
      let(:name) { '12345678901' }

      it 'is invalid with a name' do
        expect(category).not_to be_valid
      end
    end
  end
end
