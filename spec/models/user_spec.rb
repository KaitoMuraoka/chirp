require 'rails_helper'

RSpec.describe User, type: :model do
  describe "name" do
    it "必須であること" do
      user = build(:user, name: "")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "30文字までは有効であること" do
      expect(build(:user, name: "あ" * 30)).to be_valid
    end

    it "31文字以上は無効であること" do
      expect(build(:user, name: "あ" * 31)).not_to be_valid
    end
  end

  describe "email_address" do
    it "登録済みのメールアドレスでは無効であること" do
      create(:user, email_address: "taken@example.com")
      user = build(:user, email_address: "taken@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to be_present
    end
  end
end
