require "rails_helper"

RSpec.describe CreateUserUsecase, type: :usecase do
  describe "#perform" do
    let(:usecase) { described_class.perform(line_id, name) }
    let(:line_id) { "xxxxxxx" }
    let(:name) { "username" }

    it "succeeds in creating a new user" do
      expect { usecase }.to change(User, :count).from(0).to(1)
    end
  end
end
