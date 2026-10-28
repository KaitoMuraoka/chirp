# このプロジェクトについて

- Rails 8.1 の学習用アプリ「Chirp」（小さなTwitter風アプリ）
- 開発者はRails初心者。変更のたびに、何をなぜ変えたかを日本語で短く説明すること

# 開発の進め方（TDD）

- テストは RSpec（rspec-rails）で spec/ に書く。テストデータは FactoryBot で作り、fixtures や Minitest は使わない
- コントローラや画面の振る舞いは request spec（spec/requests/）、モデルは model spec（spec/models/）で書く
- 「テストを書いて」と頼まれたら、spec だけを書き、実装コードは書かない。
  書いたら bundle exec rspec を実行し、どの example がどんな理由で失敗したかを報告する
- 「実装して」と頼まれたら、spec を通す最小限のコードを書く。spec/ 配下のファイルは変更しない。
  spec を変えるべきだと考えたら、変更せずに理由を説明して判断を仰ぐ
- 実装後は bundle exec rspec をすべて実行し、結果を報告する

# 作業ルール

- Railsの規約とジェネレーター（bin/rails generate）を優先して使う
- gemを追加する前に、理由を説明して許可を取る
- 1回の依頼で変更するのは、依頼された範囲だけにする
