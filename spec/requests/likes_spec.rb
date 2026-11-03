require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:alice) { create(:user, name: "アリス") }
  let(:bob) { create(:user, name: "ボブ") }
  let!(:bob_post) { create(:post, user: bob, body: "ボブの投稿") }

  def button_labels_in_article(body)
    article = css_select("article").find { |node| node.css("p").text.strip == body }
    article.css("button").map { |button| button.text.strip }
  end

  describe "POST /posts/:post_id/like" do
    context "未ログインのとき" do
      it "いいねできないこと" do
        expect { post post_like_path(bob_post) }.not_to change(Like, :count)
      end

      it "ログイン画面に移動すること" do
        post post_like_path(bob_post)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "ログイン中のとき" do
      before { sign_in_as(alice) }

      it "いいねの数が1増えること" do
        expect { post post_like_path(bob_post) }.to change { bob_post.likes.count }.by(1)
      end

      it "タイムラインの表示が「♥ 1」になること" do
        post post_like_path(bob_post)
        get posts_path
        expect(button_labels_in_article("ボブの投稿")).to include("♥ 1")
      end

      it "2回いいねしても1件にしかならないこと" do
        expect { 2.times { post post_like_path(bob_post) } }.to change { bob_post.likes.count }.by(1)
      end

      it "2回目のいいねでもエラーにならず、トップページに戻ること" do
        2.times { post post_like_path(bob_post) }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /posts/:post_id/like" do
    before do
      create(:like, user: alice, post: bob_post)
      create(:like, user: bob, post: bob_post)
      sign_in_as(alice)
    end

    it "自分のいいねだけが取り消され、数が1減ること" do
      expect { delete post_like_path(bob_post) }.to change { bob_post.likes.count }.by(-1)
      expect(bob_post.liked_by?(alice)).to be(false)
      expect(bob_post.liked_by?(bob)).to be(true)
    end

    it "タイムラインの表示が「♡ 数」に戻ること" do
      delete post_like_path(bob_post)
      get posts_path
      expect(button_labels_in_article("ボブの投稿")).to include("♡ 1")
    end
  end

  describe "タイムラインのいいねボタン" do
    let!(:other_post) { create(:post, user: bob, body: "別の投稿") }
    let!(:alice_post) { create(:post, user: alice, body: "アリスの投稿") }

    before do
      create(:like, user: alice, post: bob_post)
      create(:like, user: bob, post: bob_post)
      create(:like, user: bob, post: other_post)
      sign_in_as(alice)
      get posts_path
    end

    context "いいね済みの投稿のとき" do
      it "「♥ 数」を表示すること" do
        expect(button_labels_in_article("ボブの投稿")).to include("♥ 2")
      end

      it "ボタンを押すといいねを取り消せること" do
        assert_select "form[action=?] input[name=_method][value=delete]", post_like_path(bob_post)
      end
    end

    context "未いいねの投稿のとき" do
      it "他の人のいいねも数えて「♡ 数」を表示すること" do
        expect(button_labels_in_article("別の投稿")).to include("♡ 1")
      end

      it "いいねが0件なら「♡ 0」を表示すること" do
        expect(button_labels_in_article("アリスの投稿")).to include("♡ 0")
      end

      it "ボタンを押すといいねできること" do
        assert_select "form[action=?]", post_like_path(other_post)
        assert_select "form[action=?] input[name=_method]", post_like_path(other_post), count: 0
      end
    end
  end
end
