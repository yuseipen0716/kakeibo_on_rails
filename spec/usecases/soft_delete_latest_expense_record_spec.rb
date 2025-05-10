require "rails_helper"

RSpec.describe SoftDeleteLatestExpenseRecordUsecase, type: :usecase do
  describe ".perform" do
    let(:usecase) { described_class.new(user) }
    let(:user) { create(:user) }

    before do
      create(:expense_record, user:)
    end

    it "最新の家計簿データのis_disabledがtrueになる。" do
      usecase.perform
      expect(user.expense_records.last.is_disabled).to be_truthy
    end
  end
end
