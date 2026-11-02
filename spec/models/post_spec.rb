require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "body" do
    it "140文字までは有効であること" do
      expect(build(:post, body: "あ" * 140)).to be_valid
    end

    it "141文字以上は無効であること" do
      post = build(:post, body: "あ" * 141)
      expect(post).not_to be_valid
      expect(post.errors[:body]).to be_present
    end

    it "空では無効であること" do
      post = build(:post, body: "")
      expect(post).not_to be_valid
      expect(post.errors[:body]).to be_present
    end
  end

  describe "user" do
    it "投稿者がいなければ無効であること" do
      post = build(:post, user: nil)
      expect(post).not_to be_valid
      expect(post.errors[:user]).to be_present
    end
  end
end
