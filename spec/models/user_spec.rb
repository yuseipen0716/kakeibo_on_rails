require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "belongs to group optionally" do
      user = User.new
      expect(user.group).to be_nil
    end

    it "has many expense_records" do
      expect(User.reflect_on_association(:expense_records).macro).to eq(:has_many)
    end
  end

  describe "talk_mode enum" do
    it "has all expected talk_mode values" do
      expected_values = {
        "default_mode" => 0,
        "input_mode" => 1,
        "show_mode" => 2,
        "group_mode" => 3,
        "expense_input_mode" => 4,
        "income_input_mode" => 5,
        "group_creating_mode" => 6,
        "group_joining_mode" => 7,
        "group_leaving_confirmation_mode" => 8
      }
      expect(User.talk_modes).to eq(expected_values)
    end
  end

  describe "talk_mode transitions" do
    let(:user) { create(:user) }

    it "can transition to group_creating_mode" do
      user.update(talk_mode: :group_creating_mode)
      expect(user.group_creating_mode?).to be true
    end

    it "can transition to group_joining_mode" do
      user.update(talk_mode: :group_joining_mode)
      expect(user.group_joining_mode?).to be true
    end

    it "can transition to group_leaving_confirmation_mode" do
      user.update(talk_mode: :group_leaving_confirmation_mode)
      expect(user.group_leaving_confirmation_mode?).to be true
    end
  end
end
