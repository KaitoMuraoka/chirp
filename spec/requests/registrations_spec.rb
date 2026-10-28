require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    it "登録画面を表示できること" do
      get new_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /registration" do
    context "正しい入力のとき" do
      let(:params) do
        { user: { name: "花子", email_address: "hanako@example.com", password: "password", password_confirmation: "password" } }
      end

      it "ユーザーが1人増えること" do
        expect { post registration_path, params: params }.to change(User, :count).by(1)
      end

      it "ログイン状態になり、トップページにリダイレクトされること" do
        post registration_path, params: params
        expect(cookies[:session_id]).to be_present
        expect(response).to redirect_to(root_path)
      end
    end

    context "名前が空のとき" do
      let(:params) do
        { user: { name: "", email_address: "hanako@example.com", password: "password", password_confirmation: "password" } }
      end

      it "登録されないこと" do
        expect { post registration_path, params: params }.not_to change(User, :count)
      end

      it "422を返し、エラーメッセージを表示すること" do
        post registration_path, params: params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("名前を入力してください")
      end
    end
  end
end
