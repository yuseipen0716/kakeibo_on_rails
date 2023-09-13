require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validation of name' do
    let(:group) { Group.new(name:) }
    context 'name length within 10' do
      let(:name) { '1234567890' }

      it 'is valid with a name' do
        expect(group).to be_valid
      end
    end

    context 'name length is over 10' do
      let(:name) { '12345678901' }

      it 'is invalid with a name' do
        expect(group).not_to be_valid
      end
    end
  end
end
