require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:alice) { create(:user, name: "アリス") }
  let(:bob) { create(:user, name: "ボブ") }
  let!(:alice_post) { create(:post, user: alice, body: "アリスの投稿", created_at: 1.hour.ago) }
  let!(:bob_post) { create(:post, user: bob, body: "ボブの投稿") }

  def timeline
    css_select("article").map { |article| [ article.css("strong").text.strip, article.css("p").text.strip ] }
  end

  describe "GET /posts" do
    context "未ログインのとき" do
      it "投稿の本文と投稿者名を見られること" do
        get posts_path
        expect(response).to have_http_status(:ok)
        expect(timeline).to contain_exactly([ "アリス", "アリスの投稿" ], [ "ボブ", "ボブの投稿" ])
      end

      it "新しい投稿が先に並ぶこと" do
        get posts_path
        expect(timeline).to eq([ [ "ボブ", "ボブの投稿" ], [ "アリス", "アリスの投稿" ] ])
      end

      it "投稿フォームを表示しないこと" do
        get posts_path
        assert_select "form[action=?]", posts_path, count: 0
      end
    end
  end

  describe "POST /posts" do
    context "未ログインのとき" do
      let(:params) { { post: { body: "新しい投稿" } } }

      it "投稿できないこと" do
        expect { post posts_path, params: params }.not_to change(Post, :count)
      end

      it "ログイン画面に移動すること" do
        post posts_path, params: params
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "ログイン中のとき" do
      before { sign_in_as(alice) }

      it "投稿できること" do
        expect { post posts_path, params: { post: { body: "新しい投稿" } } }.to change(Post, :count).by(1)
      end

      it "投稿者が自分になること" do
        post posts_path, params: { post: { body: "新しい投稿" } }
        expect(Post.find_by(body: "新しい投稿").user).to eq(alice)
      end

      it "user_id を送っても無視し、投稿者が自分になること" do
        post posts_path, params: { post: { body: "新しい投稿", user_id: bob.id } }
        expect(Post.find_by(body: "新しい投稿").user).to eq(alice)
      end

      context "本文が空のとき" do
        let(:params) { { post: { body: "" } } }

        it "投稿できないこと" do
          expect { post posts_path, params: params }.not_to change(Post, :count)
        end

        it "422を返し、エラーメッセージを表示すること" do
          post posts_path, params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("本文を入力してください")
        end
      end

      context "本文が141文字以上のとき" do
        let(:params) { { post: { body: "あ" * 141 } } }

        it "投稿できないこと" do
          expect { post posts_path, params: params }.not_to change(Post, :count)
        end

        it "422を返し、エラーメッセージを表示すること" do
          post posts_path, params: params
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("140文字以下で入力してください")
        end
      end
    end
  end

  describe "削除する" do
    before { sign_in_as(alice) }

    context "自分の投稿のとき" do
      it "削除できること" do
        expect { delete post_path(alice_post) }.to change(Post, :count).by(-1)
        expect(Post.exists?(alice_post.id)).to be(false)
      end

      it "トップページに戻ること" do
        delete post_path(alice_post)
        expect(response).to redirect_to(root_path)
      end
    end

    context "他人の投稿のとき" do
      it "削除できないこと" do
        expect { delete post_path(bob_post) }.not_to change(Post, :count)
      end

      it "404を返すこと" do
        delete post_path(bob_post)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "削除ボタンの表示" do
      def button_labels_in_article(body)
        article = css_select("article").find { |node| node.css("p").text.strip == body }
        article.css("button").map { |button| button.text.strip }
      end

      before { get posts_path }

      it "自分の投稿には表示すること" do
        expect(button_labels_in_article("アリスの投稿")).to include("削除")
      end

      it "他人の投稿には表示しないこと" do
        expect(button_labels_in_article("ボブの投稿")).not_to include("削除")
      end
    end
  end
end
