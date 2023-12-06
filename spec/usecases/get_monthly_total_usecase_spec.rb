require 'rails_helper'

RSpec.describe GetMonthlyTotalUsecase, type: :usecase do
  describe 'perform' do
    let(:usecase) { described_class.perform(user: user, period: period, category: category) }
  end
end
