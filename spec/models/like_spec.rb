require 'rails_helper'

RSpec.describe Like, type: :model do
  describe "二重いいねの防止" do
    let(:user) { create(:user) }
    let(:liked_post) { create(:post) }

    before { create(:like, user: user, post: liked_post) }

    it "同じユーザーは同じ投稿に二重でいいねできないこと" do
      expect(build(:like, user: user, post: liked_post)).not_to be_valid
    end

    it "別のユーザーなら同じ投稿にいいねできること" do
      expect(build(:like, user: create(:user), post: liked_post)).to be_valid
    end

    it "同じユーザーでも別の投稿ならいいねできること" do
      expect(build(:like, user: user, post: create(:post))).to be_valid
    end
  end
end
