require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /session" do
    it "正しいパスワードでログインするとトップページに移動すること" do
      sign_in_as(user)
      expect(response).to redirect_to(root_path)
      expect(cookies[:session_id]).to be_present
    end

    it "パスワードが違うとログインできないこと" do
      sign_in_as(user, password: "wrong")
      expect(response).to redirect_to(new_session_path)
      expect(cookies[:session_id]).to be_blank
    end
  end

  describe "DELETE /session" do
    it "ログアウトするとログイン状態が解除されること" do
      sign_in_as(user)
      delete session_path
      expect(cookies[:session_id]).to be_blank
    end
  end
end
