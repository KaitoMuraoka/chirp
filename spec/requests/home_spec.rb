require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "未ログインのとき" do
      it "ログインとユーザー登録のリンクを表示すること" do
        get root_path
        expect(response.body).to include(%(href="#{new_session_path}"))
        expect(response.body).to include(%(href="#{new_registration_path}"))
      end
    end

    context "ログイン中のとき" do
      it "「（名前）さん」とログアウトボタンを表示すること" do
        sign_in_as(create(:user, name: "太郎"))
        get root_path
        expect(response.body).to include("太郎さん")
        expect(response.body).to include("ログアウト")
      end
    end
  end
end
